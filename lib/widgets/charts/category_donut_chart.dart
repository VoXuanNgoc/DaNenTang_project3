import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/category_expense.dart';
import '../../painters/donut_chart_painter.dart';

class CategoryDonutChart extends StatefulWidget {
  final List<CategoryExpense> categories;
  final double totalAmount;

  const CategoryDonutChart({
    super.key,
    required this.categories,
    required this.totalAmount,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CategoryDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
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

    if (widget.categories.isEmpty || widget.totalAmount <= 0) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Chưa có dữ liệu danh mục',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(200, 200),
                    painter: DonutChartPainter(
                      categories: widget.categories,
                      animationProgress: _animation.value,
                      isDark: isDark,
                      strokeWidth: 30,
                    ),
                  );
                },
              ),
              // Center hole content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng chi',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(widget.totalAmount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.tealAccent : const Color(0xFF00695C),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Legends list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.categories.length,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final cat = widget.categories[index];
            final color = AppConstants.getCategoryColor(cat.category, isDark: isDark);
            final percentageStr = '${(cat.percentage * 100).toStringAsFixed(1)}%';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    AppConstants.getCategoryIcon(cat.category),
                    size: 18,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cat.category,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(cat.totalAmount),
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      percentageStr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
