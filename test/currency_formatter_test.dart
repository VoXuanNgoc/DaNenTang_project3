import 'package:flutter_test/flutter_test.dart';
import 'package:vku_expense_ocr/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('format formats numbers with Vietnamese dot separators and currency suffix', () {
      expect(CurrencyFormatter.format(65000), equals('65.000 đ'));
      expect(CurrencyFormatter.format(120000), equals('120.000 đ'));
      expect(CurrencyFormatter.format(1250000), equals('1.250.000 đ'));
      expect(CurrencyFormatter.format(0), equals('0 đ'));
    });

    test('formatWithoutSymbol formats without đ suffix', () {
      expect(CurrencyFormatter.formatWithoutSymbol(65000), equals('65.000'));
      expect(CurrencyFormatter.formatWithoutSymbol(1250000), equals('1.250.000'));
    });

    test('parseAmount parses various Vietnamese and standard number representations', () {
      expect(CurrencyFormatter.parseAmount('65.000'), equals(65000.0));
      expect(CurrencyFormatter.parseAmount('65,000'), equals(65000.0));
      expect(CurrencyFormatter.parseAmount('65000'), equals(65000.0));
      expect(CurrencyFormatter.parseAmount('1.250.000 đ'), equals(1250000.0));
      expect(CurrencyFormatter.parseAmount('120.000 VND'), equals(120000.0));
      expect(CurrencyFormatter.parseAmount(''), isNull);
      expect(CurrencyFormatter.parseAmount(null), isNull);
    });
  });
}
