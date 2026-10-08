import 'package:flutter/material.dart';

class AppConstants {
  static const String appTitle = 'VKU Expense OCR';
  static const String databaseName = 'vku_expense_ocr.db';
  static const int databaseVersion = 1;
  static const String receiptsTable = 'receipts';

  // Categories
  static const String categoryFood = 'Ăn uống';
  static const String categoryShopping = 'Mua sắm';
  static const String categoryTransport = 'Di chuyển';
  static const String categoryUtilities = 'Hóa đơn';
  static const String categoryEntertainment = 'Giải trí';
  static const String categoryHealth = 'Sức khỏe';
  static const String categoryOther = 'Khác';

  static const List<String> categories = [
    categoryFood,
    categoryShopping,
    categoryTransport,
    categoryUtilities,
    categoryEntertainment,
    categoryHealth,
    categoryOther,
  ];

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case categoryFood:
        return Icons.restaurant_rounded;
      case categoryShopping:
        return Icons.shopping_bag_rounded;
      case categoryTransport:
        return Icons.directions_car_rounded;
      case categoryUtilities:
        return Icons.receipt_long_rounded;
      case categoryEntertainment:
        return Icons.movie_rounded;
      case categoryHealth:
        return Icons.medical_services_rounded;
      case categoryOther:
      default:
        return Icons.category_rounded;
    }
  }

  static Color getCategoryColor(String category, {bool isDark = false}) {
    switch (category) {
      case categoryFood:
        return isDark ? const Color(0xFFFF8A65) : const Color(0xFFE64A19);
      case categoryShopping:
        return isDark ? const Color(0xFF81D4FA) : const Color(0xFF0288D1);
      case categoryTransport:
        return isDark ? const Color(0xFFAED581) : const Color(0xFF558B2F);
      case categoryUtilities:
        return isDark ? const Color(0xFFFFD54F) : const Color(0xFFF57F17);
      case categoryEntertainment:
        return isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);
      case categoryHealth:
        return isDark ? const Color(0xFFEF9A9A) : const Color(0xFFD32F2F);
      case categoryOther:
      default:
        return isDark ? const Color(0xFFB0BEC5) : const Color(0xFF546E7A);
    }
  }
}
