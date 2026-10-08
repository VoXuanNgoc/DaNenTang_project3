import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/receipt.dart';
import '../repositories/receipt_repository.dart';

final receiptRepositoryProvider = Provider<IReceiptRepository>((ref) {
  return ReceiptRepository();
});

class ReceiptController extends AsyncNotifier<List<Receipt>> {
  @override
  FutureOr<List<Receipt>> build() async {
    return _fetchReceipts();
  }

  Future<List<Receipt>> _fetchReceipts() async {
    final repository = ref.read(receiptRepositoryProvider);
    return await repository.getAllReceipts();
  }

  /// Reloads all receipts from the database
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchReceipts());
  }

  /// Adds a new receipt and updates local state
  Future<int> addReceipt(Receipt receipt) async {
    final repository = ref.read(receiptRepositoryProvider);
    final id = await repository.insertReceipt(receipt);
    final newReceipt = receipt.copyWith(id: id);

    state.whenData((currentList) {
      final updated = [newReceipt, ...currentList];
      // Keep sorted by date descending
      updated.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(updated);
    });

    return id;
  }

  /// Updates an existing receipt
  Future<void> updateReceipt(Receipt receipt) async {
    final repository = ref.read(receiptRepositoryProvider);
    await repository.updateReceipt(receipt);

    state.whenData((currentList) {
      final updated = currentList.map((r) => r.id == receipt.id ? receipt : r).toList();
      updated.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(updated);
    });
  }

  /// Deletes a receipt by id
  Future<void> deleteReceipt(int id) async {
    final repository = ref.read(receiptRepositoryProvider);
    await repository.deleteReceipt(id);

    state.whenData((currentList) {
      final updated = currentList.where((r) => r.id != id).toList();
      state = AsyncValue.data(updated);
    });
  }

  /// Populates demo sample data if user chooses demo mode
  Future<void> loadSampleData() async {
    state = const AsyncValue.loading();
    final repository = ref.read(receiptRepositoryProvider);
    final now = DateTime.now();

    final samples = [
      Receipt(
        merchantName: 'Highlands Coffee Đà Nẵng',
        amount: 65000.0,
        date: now.subtract(const Duration(hours: 3)),
        category: AppConstants.categoryFood,
        note: 'Cà phê Phin Sữa Đá size L',
        rawOcrText: 'HIGHLANDS COFFEE\n01 Phin Sua Da (L): 65.000\nTONG TIEN: 65.000 VND\nNgay: ${now.day}/${now.month}/${now.year}',
        createdAt: now,
        updatedAt: now,
      ),
      Receipt(
        merchantName: 'WinMart+ Ngũ Hành Sơn',
        amount: 245000.0,
        date: now.subtract(const Duration(days: 1, hours: 2)),
        category: AppConstants.categoryShopping,
        note: 'Bánh mì, sữa chua và trái cây',
        rawOcrText: 'WINMART+\nSua tuoi tiệt trùng: 35.000\nTrai cay nhap khau: 210.000\nTHANH TOAN: 245.000 đ',
        createdAt: now,
        updatedAt: now,
      ),
      Receipt(
        merchantName: 'Grab Taxi',
        amount: 85000.0,
        date: now.subtract(const Duration(days: 2, hours: 5)),
        category: AppConstants.categoryTransport,
        note: 'Di chuyển từ VKU về trung tâm',
        rawOcrText: 'GRAB TAXI VIETNAM\nCuoc phi chuyen di: 85.000\nTong cong: 85.000 VND',
        createdAt: now,
        updatedAt: now,
      ),
      Receipt(
        merchantName: 'Nhà thuốc Long Châu',
        amount: 120000.0,
        date: now.subtract(const Duration(days: 3, hours: 4)),
        category: AppConstants.categoryHealth,
        note: 'Vitamin C và khẩu trang y tế',
        rawOcrText: 'NHA THUOC FPT LONG CHAU\nVitamin C: 80.000\nKhau trang 4D: 40.000\nTONG TIEN: 120.000',
        createdAt: now,
        updatedAt: now,
      ),
      Receipt(
        merchantName: 'Điện Lực Đà Nẵng (EVN)',
        amount: 350000.0,
        date: now.subtract(const Duration(days: 5)),
        category: AppConstants.categoryUtilities,
        note: 'Tiền điện sinh hoạt tháng này',
        rawOcrText: 'EVN CPC\nTIEN DIEN SINH HOAT\nTHANH TOAN: 350.000 VND',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final s in samples) {
      await repository.insertReceipt(s);
    }

    state = await AsyncValue.guard(() => _fetchReceipts());
  }

  /// Clears all receipts
  Future<void> clearAll() async {
    state = const AsyncValue.loading();
    final repository = ref.read(receiptRepositoryProvider);
    await repository.clearAll();
    state = const AsyncValue.data([]);
  }
}
