import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _weekdayFormat = DateFormat('E, dd/MM', 'vi');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatWeekday(DateTime date) {
    return _weekdayFormat.format(date);
  }

  /// Parses date strings commonly found in Vietnamese receipts.
  /// Supports:
  /// - dd/MM/yyyy
  /// - dd-MM-yyyy
  /// - dd.MM.yyyy
  /// - yyyy-MM-dd
  /// - yyyy/MM/dd
  static DateTime? parseDate(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // Pattern 1: dd/MM/yyyy or dd-MM-yyyy or dd.MM.yyyy
    final dmyRegex = RegExp(r'(\d{1,2})[/\.-](\d{1,2})[/\.-](\d{4})');
    final dmyMatch = dmyRegex.firstMatch(trimmed);
    if (dmyMatch != null) {
      final day = int.tryParse(dmyMatch.group(1)!);
      final month = int.tryParse(dmyMatch.group(2)!);
      final year = int.tryParse(dmyMatch.group(3)!);
      if (day != null && month != null && year != null) {
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          return DateTime(year, month, day);
        }
      }
    }

    // Pattern 2: yyyy-MM-dd or yyyy/MM/dd
    final ymdRegex = RegExp(r'(\d{4})[/\.-](\d{1,2})[/\.-](\d{1,2})');
    final ymdMatch = ymdRegex.firstMatch(trimmed);
    if (ymdMatch != null) {
      final year = int.tryParse(ymdMatch.group(1)!);
      final month = int.tryParse(ymdMatch.group(2)!);
      final day = int.tryParse(ymdMatch.group(3)!);
      if (year != null && month != null && day != null) {
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          return DateTime(year, month, day);
        }
      }
    }

    // Pattern 3: dd/MM/yy
    final dmyShortRegex = RegExp(r'(\d{1,2})[/\.-](\d{1,2})[/\.-](\d{2})');
    final dmyShortMatch = dmyShortRegex.firstMatch(trimmed);
    if (dmyShortMatch != null) {
      final day = int.tryParse(dmyShortMatch.group(1)!);
      final month = int.tryParse(dmyShortMatch.group(2)!);
      var year = int.tryParse(dmyShortMatch.group(3)!);
      if (day != null && month != null && year != null) {
        year += 2000;
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          return DateTime(year, month, day);
        }
      }
    }

    return null;
  }
}
