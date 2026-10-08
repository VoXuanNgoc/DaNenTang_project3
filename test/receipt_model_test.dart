import 'package:flutter_test/flutter_test.dart';
import 'package:vku_expense_ocr/core/constants/app_constants.dart';
import 'package:vku_expense_ocr/models/receipt.dart';

void main() {
  group('Receipt Model Serialization Tests', () {
    test('Receipt serialization toMap and fromMap works seamlessly', () {
      final now = DateTime(2026, 5, 15, 10, 30);
      final receipt = Receipt(
        id: 1,
        merchantName: 'Highlands Coffee Đà Nẵng',
        amount: 65000.0,
        date: now,
        category: AppConstants.categoryFood,
        imagePath: '/data/user/0/receipt.jpg',
        rawOcrText: 'HIGHLANDS COFFEE 65.000',
        note: 'Uống cùng bạn bè',
        createdAt: now,
        updatedAt: now,
      );

      final map = receipt.toMap();
      expect(map['id'], equals(1));
      expect(map['merchant_name'], equals('Highlands Coffee Đà Nẵng'));
      expect(map['amount'], equals(65000.0));
      expect(map['category'], equals(AppConstants.categoryFood));
      expect(map['image_path'], equals('/data/user/0/receipt.jpg'));

      final restored = Receipt.fromMap(map);
      expect(restored.id, equals(receipt.id));
      expect(restored.merchantName, equals(receipt.merchantName));
      expect(restored.amount, equals(receipt.amount));
      expect(restored.date, equals(receipt.date));
      expect(restored.category, equals(receipt.category));
      expect(restored.note, equals(receipt.note));
    });

    test('Receipt copyWith updates fields properly', () {
      final now = DateTime.now();
      final r1 = Receipt(
        id: 5,
        merchantName: 'Store A',
        amount: 50000.0,
        date: now,
        category: AppConstants.categoryShopping,
        createdAt: now,
        updatedAt: now,
      );

      final r2 = r1.copyWith(merchantName: 'Store B', amount: 80000.0);
      expect(r2.id, equals(5));
      expect(r2.merchantName, equals('Store B'));
      expect(r2.amount, equals(80000.0));
      expect(r2.category, equals(AppConstants.categoryShopping));
    });
  });
}
