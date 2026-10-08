import 'package:flutter_test/flutter_test.dart';
import 'package:vku_expense_ocr/core/constants/app_constants.dart';
import 'package:vku_expense_ocr/core/parsers/receipt_parser.dart';

void main() {
  group('ReceiptParser Tests', () {
    test('Extract total amount from Vietnamese receipt with TONG TIEN keyword', () {
      const sampleOcrText = '''
HIGHLANDS COFFEE
Dia chi: 123 Nguyen Van Linh, Da Nang
So HD: 98124
01 Ca phe Phin Sua Da (L)     45.000
01 Tra Sen Vang (M)           55.000
TONG TIEN: 100.000 VND
Tien mat: 100.000
Ngay: 15/05/2026 09:30
Xin cam on quy khach!
''';

      final result = ReceiptParser.parse(sampleOcrText);

      expect(result.merchantName, contains('HIGHLANDS COFFEE'));
      expect(result.amount, equals(100000.0));
      expect(result.date, isNotNull);
      expect(result.date!.day, equals(15));
      expect(result.date!.month, equals(5));
      expect(result.date!.year, equals(2026));
      expect(result.category, equals(AppConstants.categoryFood));
      expect(result.confidence, greaterThanOrEqualTo(0.7));
    });

    test('Extract total amount from receipt with THANH TOAN and dot separator', () {
      const sampleOcrText = '''
WINMART+
CUA HANG TIEN LOI
Banh mi sandwich: 22.000
Sua chua Vinamilk: 38.000
THANH TOÁN: 60.000 đ
Ngay: 20-04-2026
''';

      final result = ReceiptParser.parse(sampleOcrText);

      expect(result.merchantName, contains('WINMART+'));
      expect(result.amount, equals(60000.0));
      expect(result.date, isNotNull);
      expect(result.date!.day, equals(20));
      expect(result.date!.month, equals(4));
      expect(result.category, equals(AppConstants.categoryShopping));
    });

    test('Extract total amount with comma thousands separator', () {
      const sampleOcrText = '''
NHA THUOC LONG CHAU
Thuoc Cam Cum: 50,000
Vitamin C: 75,000
TONG CONG: 125,000 VND
Ngay 01/06/2026
''';

      final result = ReceiptParser.parse(sampleOcrText);

      expect(result.merchantName, contains('NHA THUOC LONG CHAU'));
      expect(result.amount, equals(125000.0));
      expect(result.category, equals(AppConstants.categoryHealth));
    });

    test('Extract merchant name ignoring header terms like HOA DON BAN HANG', () {
      const sampleOcrText = '''
HOA DON BAN HANG
GRAB TAXI
Ma chuyen di: GRAB12345
Tong tien: 45.000 VND
Ngay: 10/05/2026
''';

      final result = ReceiptParser.parse(sampleOcrText);

      expect(result.merchantName, equals('GRAB TAXI'));
      expect(result.amount, equals(45000.0));
      expect(result.category, equals(AppConstants.categoryTransport));
    });

    test('Empty text returns safe fallback object without crashing', () {
      final result = ReceiptParser.parse('   ');

      expect(result.amount, isNull);
      expect(result.merchantName, isNull);
      expect(result.date, isNull);
      expect(result.confidence, equals(0.0));
    });
  });
}
