import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';
import '../../models/daily_expense.dart';
import '../../painters/weekly_bar_chart_painter.dart';

class WeeklyBarChart extends StatefulWidget {
  final List<DailyExpense> dailyExpenses;

  const WeeklyBarChart({
    super.key,
    required this.dailyExpenses,
  });

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WeeklyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dailyExpenses != widget.dailyExpenses) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalWeek = widget.dailyExpenses.fold(0.0, (sum, d) => sum + d.totalAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chi tiêu 7 ngày qua',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tổng: ${CurrencyFormatter.format(totalWeek)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.tealAccent : const Color(0xFF00695C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.teal.shade900.withAlpha(80) : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 16,
                    color: isDark ? Colors.tealAccent : const Color(0xFF00695C),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '7 ngày',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.tealAccent : const Color(0xFF00695C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(double.infinity, 180),
                painter: WeeklyBarChartPainter(
                  dailyExpenses: widget.dailyExpenses,
                  animationProgress: _animation.value,
                  isDark: isDark,
                  primaryColor: theme.colorScheme.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
