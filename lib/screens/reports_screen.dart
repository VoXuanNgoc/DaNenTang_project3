import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/currency_formatter.dart';
import '../services/platform_channel_service.dart';
import '../state/receipt_providers.dart';
import '../state/theme_provider.dart';
import '../widgets/charts/category_donut_chart.dart';
import '../widgets/charts/weekly_bar_chart.dart';
import '../widgets/empty_state.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int? _batteryLevel;
  String _deviceModel = 'Đang tải...';
  bool _isLoadingDeviceInfo = true;

  @override
  void initState() {
    super.initState();
    _fetchDeviceInfo();
  }

  Future<void> _fetchDeviceInfo() async {
    final battery = await PlatformChannelService.getBatteryLevel();
    final model = await PlatformChannelService.getDeviceModel();
    if (mounted) {
      setState(() {
        _batteryLevel = battery;
        _deviceModel = model;
        _isLoadingDeviceInfo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalExpense = ref.watch(totalExpenseAmountProvider);
    final receiptCount = ref.watch(totalReceiptCountProvider);
    final categoryBreakdown = ref.watch(categoryExpensesBreakdownProvider);
    final weeklyExpenses = ref.watch(weeklyExpensesBreakdownProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo & Thống kê'),
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
        ],
      ),
      body: receiptCount == 0
          ? EmptyState(
              title: 'Chưa có dữ liệu thống kê',
              message: 'Hãy thêm hoặc quét hóa đơn chi tiêu đầu tiên để xem biểu đồ phân tích!',
              icon: Icons.insights_rounded,
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Top Summary Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF004D40), const Color(0xFF00332C)]
                            : [const Color(0xFF00796B), const Color(0xFF004D40)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng chi tiêu toàn bộ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$receiptCount hóa đơn',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(totalExpense),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Section 1: Weekly Spending Bar Chart (CustomPainter)
                Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: WeeklyBarChart(
                      dailyExpenses: weeklyExpenses,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Section 2: Category Donut Chart (CustomPainter)
                Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cơ cấu chi tiêu theo danh mục',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CategoryDonutChart(
                          categories: categoryBreakdown,
                          totalAmount: totalExpense,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Section 3: Platform Channel (Week 8 demo: battery level and native info)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.teal.shade900 : Colors.teal.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.developer_mode_rounded,
                                size: 20,
                                color: isDark ? Colors.tealAccent : const Color(0xFF00796B),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Demo MethodChannel (Week 8)',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    'vn.edu.vku/device_info',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: isDark ? Colors.white54 : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pin thiết bị (Battery Level):', style: TextStyle(fontSize: 13)),
                            Text(
                              _batteryLevel != null
                                  ? '$_batteryLevel%'
                                  : (_isLoadingDeviceInfo ? 'Đang đọc...' : 'Không khả dụng trên Desktop/Web'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _batteryLevel != null ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Mẫu thiết bị (Device Model):', style: TextStyle(fontSize: 13)),
                            Flexible(
                              child: Text(
                                _deviceModel,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
    );
  }
}
