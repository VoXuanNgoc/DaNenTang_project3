import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_expense.dart';
import '../models/daily_expense.dart';
import '../models/receipt.dart';
import 'receipt_controller.dart';

final receiptListProvider =
    AsyncNotifierProvider<ReceiptController, List<Receipt>>(() {
  return ReceiptController();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) => state = newQuery;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(() => SearchQueryNotifier());

class CategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'Tất cả';

  void selectCategory(String cat) => state = cat;
}

final selectedCategoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, String>(() => CategoryFilterNotifier());

/// Filtered receipts provider based on search query and category filter
final filteredReceiptsProvider = Provider<List<Receipt>>((ref) {
  final receiptsAsync = ref.watch(receiptListProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final categoryFilter = ref.watch(selectedCategoryFilterProvider);

  return receiptsAsync.maybeWhen(
    data: (receipts) {
      return receipts.where((receipt) {
        final matchesCategory = categoryFilter == 'Tất cả' || receipt.category == categoryFilter;
        final matchesQuery = query.isEmpty ||
            receipt.merchantName.toLowerCase().contains(query) ||
            receipt.category.toLowerCase().contains(query) ||
            (receipt.note?.toLowerCase().contains(query) ?? false);
        return matchesCategory && matchesQuery;
      }).toList();
    },
    orElse: () => [],
  );
});

/// Grand total of all expenses
final totalExpenseAmountProvider = Provider<double>((ref) {
  final receiptsAsync = ref.watch(receiptListProvider);
  return receiptsAsync.maybeWhen(
    data: (receipts) => receipts.fold(0.0, (sum, item) => sum + item.amount),
    orElse: () => 0.0,
  );
});

/// Total number of receipts
final totalReceiptCountProvider = Provider<int>((ref) {
  final receiptsAsync = ref.watch(receiptListProvider);
  return receiptsAsync.maybeWhen(
    data: (receipts) => receipts.length,
    orElse: () => 0,
  );
});

/// Top recent receipts (up to 5)
final recentReceiptsProvider = Provider<List<Receipt>>((ref) {
  final receiptsAsync = ref.watch(receiptListProvider);
  return receiptsAsync.maybeWhen(
    data: (receipts) => receipts.take(5).toList(),
    orElse: () => [],
  );
});

/// Category breakdown computation for Donut Chart
final categoryExpensesBreakdownProvider = Provider<List<CategoryExpense>>((ref) {
  final receiptsAsync = ref.watch(receiptListProvider);

  return receiptsAsync.maybeWhen(
    data: (receipts) {
      if (receipts.isEmpty) return [];

      final total = receipts.fold(0.0, (sum, r) => sum + r.amount);
      final Map<String, double> categorySums = {};
      final Map<String, int> categoryCounts = {};

      for (final r in receipts) {
        categorySums[r.category] = (categorySums[r.category] ?? 0.0) + r.amount;
        categoryCounts[r.category] = (categoryCounts[r.category] ?? 0) + 1;
      }

      final list = categorySums.entries.map((entry) {
        final cat = entry.key;
        final sum = entry.value;
        final count = categoryCounts[cat] ?? 0;
        final pct = total > 0 ? (sum / total) : 0.0;
        return CategoryExpense(
          category: cat,
          totalAmount: sum,
          count: count,
          percentage: pct,
        );
      }).toList();

      list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      return list;
    },
    orElse: () => [],
  );
});

/// 7-day spending breakdown for Weekly Bar Chart
final weeklyExpensesBreakdownProvider = Provider<List<DailyExpense>>((ref) {
  final receiptsAsync = ref.watch(receiptListProvider);

  return receiptsAsync.maybeWhen(
    data: (receipts) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDate = today.subtract(const Duration(days: 6));

      final Map<String, double> dayTotals = {};
      for (final r in receipts) {
        final d = DateTime(r.date.year, r.date.month, r.date.day);
        if (d.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            d.isBefore(today.add(const Duration(days: 1)))) {
          final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          dayTotals[key] = (dayTotals[key] ?? 0.0) + r.amount;
        }
      }

      final vietnameseWeekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
      final List<DailyExpense> list = [];

      for (int i = 0; i < 7; i++) {
        final day = startDate.add(Duration(days: i));
        final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final total = dayTotals[key] ?? 0.0;
        final weekdayIndex = day.weekday % 7;
        final label = '${vietnameseWeekdays[weekdayIndex]} (${day.day}/${day.month})';

        list.add(DailyExpense(
          date: day,
          totalAmount: total,
          label: label,
        ));
      }

      return list;
    },
    orElse: () => [],
  );
});
