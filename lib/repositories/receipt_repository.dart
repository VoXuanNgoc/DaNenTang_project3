import '../models/category_expense.dart';
import '../models/daily_expense.dart';
import '../models/receipt.dart';
import '../services/database_service.dart';

abstract class IReceiptRepository {
  Future<int> insertReceipt(Receipt receipt);
  Future<int> updateReceipt(Receipt receipt);
  Future<int> deleteReceipt(int id);
  Future<Receipt?> getReceiptById(int id);
  Future<List<Receipt>> getAllReceipts();
  Future<List<Receipt>> searchReceipts(String query);
  Future<double> getTotalAmount();
  Future<int> getReceiptCount();
  Future<List<CategoryExpense>> getCategoryExpenses();
  Future<List<DailyExpense>> getDailyExpenses({int days = 7});
  Future<void> clearAll();
}

class ReceiptRepository implements IReceiptRepository {
  final DatabaseService _databaseService;

  ReceiptRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  @override
  Future<int> insertReceipt(Receipt receipt) =>
      _databaseService.insertReceipt(receipt);

  @override
  Future<int> updateReceipt(Receipt receipt) =>
      _databaseService.updateReceipt(receipt);

  @override
  Future<int> deleteReceipt(int id) => _databaseService.deleteReceipt(id);

  @override
  Future<Receipt?> getReceiptById(int id) =>
      _databaseService.getReceiptById(id);

  @override
  Future<List<Receipt>> getAllReceipts() => _databaseService.getAllReceipts();

  @override
  Future<List<Receipt>> searchReceipts(String query) =>
      _databaseService.searchReceipts(query);

  @override
  Future<double> getTotalAmount() => _databaseService.getTotalAmount();

  @override
  Future<int> getReceiptCount() => _databaseService.getReceiptCount();

  @override
  Future<List<CategoryExpense>> getCategoryExpenses() =>
      _databaseService.getCategoryExpenses();

  @override
  Future<List<DailyExpense>> getDailyExpenses({int days = 7}) =>
      _databaseService.getDailyExpenses(days: days);

  @override
  Future<void> clearAll() => _databaseService.clearAll();
}
