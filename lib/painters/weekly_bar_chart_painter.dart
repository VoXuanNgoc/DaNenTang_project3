import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/utils/currency_formatter.dart';
import '../models/daily_expense.dart';

class WeeklyBarChartPainter extends CustomPainter {
  final List<DailyExpense> dailyExpenses;
  final double animationProgress; // 0.0 to 1.0
  final bool isDark;
  final Color primaryColor;

  WeeklyBarChartPainter({
    required this.dailyExpenses,
    required this.animationProgress,
    this.isDark = false,
    this.primaryColor = const Color(0xFF00695C),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dailyExpenses.isEmpty) return;

    final bottomPadding = 32.0;
    final topPadding = 24.0;
    final availableHeight = size.height - bottomPadding - topPadding;
    final chartWidth = size.width;

    // Find maximum spending for scaling
    final maxAmount = dailyExpenses.map((e) => e.totalAmount).fold<double>(0.0, math.max);
    final effectiveMax = maxAmount > 0 ? maxAmount * 1.15 : 100000.0;

    // Draw horizontal dashed grid lines
    final gridPaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = topPadding + (availableHeight * (i / 3));
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    final barCount = dailyExpenses.length;
    final barSpacing = chartWidth / barCount;
    final barWidth = math.min(28.0, barSpacing * 0.55);

    for (int i = 0; i < barCount; i++) {
      final item = dailyExpenses[i];
      final centerX = (i * barSpacing) + (barSpacing / 2);

      // Height calculation with animation
      final ratio = (item.totalAmount / effectiveMax).clamp(0.0, 1.0);
      final barHeight = (availableHeight * ratio * animationProgress).clamp(2.0, availableHeight);
      final barTop = topPadding + availableHeight - barHeight;
      final barBottom = topPadding + availableHeight;

      // Draw background track for bar
      final trackPaint = Paint()
        ..color = isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10)
        ..style = PaintingStyle.fill;

      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(centerX - barWidth / 2, topPadding, centerX + barWidth / 2, barBottom),
        const Radius.circular(6),
      );
      canvas.drawRRect(trackRect, trackPaint);

      // Draw active bar with gradient
      if (item.totalAmount > 0) {
        final barRect = Rect.fromLTRB(
          centerX - barWidth / 2,
          barTop,
          centerX + barWidth / 2,
          barBottom,
        );

        final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF4DB6AC), const Color(0xFF00695C)]
              : [const Color(0xFF00897B), const Color(0xFF004D40)],
        );

        final barPaint = Paint()
          ..shader = gradient.createShader(barRect)
          ..style = PaintingStyle.fill;

        final roundedBar = RRect.fromRectAndCorners(
          barRect,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
          bottomLeft: const Radius.circular(2),
          bottomRight: const Radius.circular(2),
        );
        canvas.drawRRect(roundedBar, barPaint);

        // Draw amount label above bar if space permits
        if (animationProgress > 0.7 && barHeight > 15) {
          final textSpan = TextSpan(
            text: _formatShortAmount(item.totalAmount),
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF37474F),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(centerX - (textPainter.width / 2), barTop - textPainter.height - 3),
          );
        }
      }

      // Draw weekday/date label at bottom
      final labelSpan = TextSpan(
        text: item.label.split(' ').first, // e.g. "T2"
        style: TextStyle(
          color: isDark ? Colors.white60 : Colors.black54,
          fontSize: 11,
          fontWeight: item.totalAmount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(centerX - (labelPainter.width / 2), barBottom + 8),
      );
    }
  }

  String _formatShortAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).round()}k';
    }
    return CurrencyFormatter.formatWithoutSymbol(amount);
  }

  @override
  bool shouldRepaint(covariant WeeklyBarChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.dailyExpenses != dailyExpenses ||
        oldDelegate.isDark != isDark;
  }
}
