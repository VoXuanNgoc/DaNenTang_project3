import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _viCurrencyFormat = NumberFormat('#,###', 'vi_VN');

  /// Formats double amount to Vietnamese currency representation: e.g. "65.000 đ"
  static String format(double amount) {
    final formattedNumber = _viCurrencyFormat.format(amount.round());
    return '$formattedNumber đ';
  }

  /// Formats double amount without the currency symbol: e.g. "65.000"
  static String formatWithoutSymbol(double amount) {
    return _viCurrencyFormat.format(amount.round());
  }

  /// Parses noisy raw OCR or user input string into a valid double amount.
  /// Handles formats like: "65.000", "65,000", "65000", "1.250.000 đ", "120.000VND"
  static double? parseAmount(String? raw) {
    if (raw == null) return null;
    var cleaned = raw.trim();
    if (cleaned.isEmpty) return null;

    // Remove currency symbols and characters
    cleaned = cleaned
        .replaceAll(RegExp(r'[đĐdD\sVNDvnd₫$]'), '')
        .trim();

    if (cleaned.isEmpty) return null;

    // If string has both dots and commas (e.g. 1,250.00 or 1.250,00)
    if (cleaned.contains('.') && cleaned.contains(',')) {
      final lastDot = cleaned.lastIndexOf('.');
      final lastComma = cleaned.lastIndexOf(',');
      if (lastDot > lastComma) {
        // Dot is decimal separator, comma is thousands: 1,250.50
        cleaned = cleaned.replaceAll(',', '');
      } else {
        // Comma is decimal separator, dot is thousands: 1.250,50
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      }
    } else if (cleaned.contains('.')) {
      // Could be Vietnamese thousands separator (150.000) or decimal (150.50)
      final parts = cleaned.split('.');
      if (parts.length > 2) {
        // Multiple dots => definitely thousands separators e.g. 1.250.000
        cleaned = cleaned.replaceAll('.', '');
      } else if (parts.length == 2 && parts[1].length == 3) {
        // e.g. 150.000 => Vietnamese thousands separator
        cleaned = cleaned.replaceAll('.', '');
      } else {
        // e.g. 15.5 or 150.5
        // Could be decimal
      }
    } else if (cleaned.contains(',')) {
      // Could be thousands separator (150,000) or decimal (150,5)
      final parts = cleaned.split(',');
      if (parts.length > 2) {
        cleaned = cleaned.replaceAll(',', '');
      } else if (parts.length == 2 && parts[1].length == 3) {
        cleaned = cleaned.replaceAll(',', '');
      } else {
        cleaned = cleaned.replaceAll(',', '.');
      }
    }

    return double.tryParse(cleaned);
  }
}
