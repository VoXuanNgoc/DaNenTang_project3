import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../state/receipt_providers.dart';
import '../state/theme_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/stats_metric_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final receiptsAsync = ref.watch(receiptListProvider);
    final totalExpense = ref.watch(totalExpenseAmountProvider);
    final totalCount = ref.watch(totalReceiptCountProvider);
    final filteredReceipts = ref.watch(filteredReceiptsProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF004D40) : const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF00796B),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              AppConstants.appTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đổi giao diện Sáng/Tối',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : Colors.blueGrey,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Tùy chọn',
            onSelected: (value) async {
              if (value == 'sample') {
                await ref.read(receiptListProvider.notifier).loadSampleData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã nạp dữ liệu hóa đơn mẫu')),
                  );
                }
              } else if (value == 'clear') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận xóa tất cả'),
                    content: const Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử hóa đơn?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Xóa tất cả'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(receiptListProvider.notifier).clearAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa toàn bộ hóa đơn')),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sample',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 20, color: Colors.teal),
                    SizedBox(width: 10),
                    Text('Nạp dữ liệu mẫu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Xóa toàn bộ'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: receiptsAsync.when(
        loading: () => const LoadingView(message: 'Đang tải danh sách chi tiêu...'),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Lỗi: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(receiptListProvider.notifier).refresh(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (receipts) {
          if (receipts.isEmpty) {
            return EmptyState(
              title: 'Chưa có chi tiêu nào',
              message: 'Quét hóa đơn bằng camera hoặc thêm chi tiêu thủ công để bắt đầu theo dõi tài chính!',
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/scan'),
                    icon: const Icon(Icons.document_scanner_rounded),
                    label: const Text('Quét hóa đơn'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/add'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Thêm thủ công'),
                  ),
                ],
              ),
            );
          }

          final avgExpense = totalCount > 0 ? (totalExpense / totalCount) : 0.0;

          return RefreshIndicator(
            onRefresh: () => ref.read(receiptListProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                // Summary Metric Cards
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: StatsMetricCard(
                          title: 'Tổng chi tiêu',
                          value: CurrencyFormatter.format(totalExpense),
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFF00796B),
                          subtitle: '$totalCount hóa đơn đã lưu',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: StatsMetricCard(
                          title: 'Trung bình',
                          value: CurrencyFormatter.format(avgExpense),
                          icon: Icons.analytics_rounded,
                          color: Colors.indigo,
                          subtitle: 'mỗi hóa đơn',
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/scan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.camera_alt_rounded, size: 20),
                          label: const Text('Quét hóa đơn OCR', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/add'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.edit_note_rounded, size: 20),
                          label: const Text('Thêm thủ công', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm cửa hàng, ghi chú...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).updateQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      ref.read(searchQueryProvider.notifier).updateQuery(val);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Category Filter Chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    children: [
                      _buildCategoryChip('Tất cả', selectedCategory),
                      ...AppConstants.categories.map((c) => _buildCategoryChip(c, selectedCategory)),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Header for Recent Receipts
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lịch sử hóa đơn (${filteredReceipts.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/reports'),
                        icon: const Icon(Icons.bar_chart_rounded, size: 18),
                        label: const Text('Xem báo cáo'),
                      ),
                    ],
                  ),
                ),

                // Receipt List
                if (filteredReceipts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Không tìm thấy hóa đơn phù hợp',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredReceipts.length,
                    itemBuilder: (context, index) {
                      final receipt = filteredReceipts[index];
                      return ExpenseSummaryCard(
                        key: ValueKey(receipt.id),
                        merchant: receipt.merchantName,
                        amount: receipt.amount,
                        date: receipt.date,
                        category: receipt.category,
                        onTap: () {
                          if (receipt.id != null) {
                            context.push('/expense/${receipt.id}');
                          }
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String categoryName, String selectedCategory) {
    final isSelected = categoryName == selectedCategory;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(categoryName),
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        backgroundColor: isDark ? const Color(0xFF1E2630) : Colors.white,
        selectedColor: isDark ? const Color(0xFF00796B) : const Color(0xFF00695C),
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : (isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        onSelected: (selected) {
          ref.read(selectedCategoryFilterProvider.notifier).selectCategory(categoryName);
        },
      ),
    );
  }
}
