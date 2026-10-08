import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/category_expense.dart';

class DonutChartPainter extends CustomPainter {
  final List<CategoryExpense> categories;
  final double animationProgress; // 0.0 to 1.0
  final bool isDark;
  final double strokeWidth;

  DonutChartPainter({
    required this.categories,
    required this.animationProgress,
    this.isDark = false,
    this.strokeWidth = 34.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    if (categories.isEmpty) {
      // Draw placeholder track
      final emptyPaint = Paint()
        ..color = isDark ? Colors.white12 : Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, emptyPaint);
      return;
    }

    // Draw background track
    final bgPaint = Paint()
      ..color = isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final total = categories.fold(0.0, (sum, c) => sum + c.totalAmount);
    if (total <= 0) return;

    var startAngle = -math.pi / 2; // Start from top 12 o'clock

    for (final item in categories) {
      if (item.totalAmount <= 0) continue;

      final sliceRatio = item.totalAmount / total;
      final fullSweepAngle = sliceRatio * 2 * math.pi;
      // Animate the sweep angle
      final sweepAngle = fullSweepAngle * animationProgress;

      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = AppConstants.getCategoryColor(item.category, isDark: isDark)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      // Draw arc slightly reduced by gap if multiple categories
      final gap = categories.length > 1 ? 0.03 : 0.0;
      final effectiveSweep = math.max(0.001, sweepAngle - gap);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (gap / 2),
        effectiveSweep,
        false,
        paint,
      );

      startAngle += fullSweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.categories != categories ||
        oldDelegate.isDark != isDark;
  }
}
