import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../core/constants/app_constants.dart';
import '../models/category_expense.dart';
import '../models/daily_expense.dart';
import '../models/receipt.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // If running on desktop platforms (Windows/Linux/macOS), initialize FFI
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.receiptsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        merchant_name TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        image_path TEXT,
        raw_ocr_text TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indices for faster queries
    await db.execute(
      'CREATE INDEX idx_receipts_date ON ${AppConstants.receiptsTable} (date)',
    );
    await db.execute(
      'CREATE INDEX idx_receipts_category ON ${AppConstants.receiptsTable} (category)',
    );
  }

  /// Inserts a new receipt and returns the created ID
  Future<int> insertReceipt(Receipt receipt) async {
    final db = await database;
    final map = receipt.toMap();
    map.remove('id'); // SQLite will auto-assign
    return await db.insert(
      AppConstants.receiptsTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing receipt
  Future<int> updateReceipt(Receipt receipt) async {
    if (receipt.id == null) {
      throw ArgumentError('Cannot update receipt without an id');
    }
    final db = await database;
    return await db.update(
      AppConstants.receiptsTable,
      receipt.toMap(),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }

  /// Deletes a receipt by id
  Future<int> deleteReceipt(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.receiptsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets a receipt by id
  Future<Receipt?> getReceiptById(int id) async {
    final db = await database;
    final results = await db.query(
      AppConstants.receiptsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return Receipt.fromMap(results.first);
    }
    return null;
  }

  /// Gets all receipts ordered by date descending
  Future<List<Receipt>> getAllReceipts() async {
    final db = await database;
    final results = await db.query(
      AppConstants.receiptsTable,
      orderBy: 'date DESC, id DESC',
    );
    return results.map((map) => Receipt.fromMap(map)).toList();
  }

  /// Search receipts by merchant name, category, or note
  Future<List<Receipt>> searchReceipts(String query) async {
    final db = await database;
    final sanitized = '%$query%';
    final results = await db.query(
      AppConstants.receiptsTable,
      where: 'merchant_name LIKE ? OR category LIKE ? OR note LIKE ?',
      whereArgs: [sanitized, sanitized, sanitized],
      orderBy: 'date DESC',
    );
    return results.map((map) => Receipt.fromMap(map)).toList();
  }

  /// Calculates the grand total of all expenses
  Future<double> getTotalAmount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM ${AppConstants.receiptsTable}',
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  /// Counts total receipts
  Future<int> getReceiptCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.receiptsTable}'),
    );
    return count ?? 0;
  }

  /// Aggregates expenses by category with percentages
  Future<List<CategoryExpense>> getCategoryExpenses() async {
    final db = await database;
    final totalAmount = await getTotalAmount();

    final results = await db.rawQuery('''
      SELECT category, SUM(amount) as total_amount, COUNT(*) as item_count
      FROM ${AppConstants.receiptsTable}
      GROUP BY category
      ORDER BY total_amount DESC
    ''');

    return results.map((row) {
      final amount = (row['total_amount'] as num?)?.toDouble() ?? 0.0;
      final count = (row['item_count'] as num?)?.toInt() ?? 0;
      final percentage = totalAmount > 0 ? (amount / totalAmount) : 0.0;

      return CategoryExpense(
        category: row['category'] as String,
        totalAmount: amount,
        count: count,
        percentage: percentage,
      );
    }).toList();
  }

  /// Aggregates spending for the last 7 days (or given number of days)
  Future<List<DailyExpense>> getDailyExpenses({int days = 7}) async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: days - 1));

    final results = await db.rawQuery('''
      SELECT SUBSTR(date, 1, 10) as day_date, SUM(amount) as day_total
      FROM ${AppConstants.receiptsTable}
      WHERE date >= ?
      GROUP BY SUBSTR(date, 1, 10)
      ORDER BY day_date ASC
    ''', [startDate.toIso8601String()]);

    final Map<String, double> map = {};
    for (final row in results) {
      final key = row['day_date'] as String;
      final amt = (row['day_total'] as num?)?.toDouble() ?? 0.0;
      map[key] = amt;
    }

    final List<DailyExpense> list = [];
    final vietnameseWeekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    for (int i = 0; i < days; i++) {
      final d = startDate.add(Duration(days: i));
      final dateKey = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final total = map[dateKey] ?? 0.0;
      final weekdayIndex = d.weekday % 7; // Sunday is 0, Mon is 1...
      final label = '${vietnameseWeekdays[weekdayIndex]} (${d.day}/${d.month})';

      list.add(DailyExpense(
        date: d,
        totalAmount: total,
        label: label,
      ));
    }

    return list;
  }

  /// Resets database (helpful for testing and clean slate)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(AppConstants.receiptsTable);
  }

  /// Closes database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
