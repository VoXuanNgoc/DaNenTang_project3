import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final String merchant;
  final double amount;
  final DateTime date;
  final VoidCallback onTap;
  final String? category;

  const ExpenseSummaryCard({
    super.key,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.onTap,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catName = category ?? AppConstants.categoryOther;
    final catColor = AppConstants.getCategoryColor(catName, isDark: isDark);
    final catIcon = AppConstants.getCategoryIcon(catName);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: catColor.withAlpha(isDark ? 50 : 35),
                ),
                child: Icon(
                  catIcon,
                  color: catColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Merchant name & date column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      merchant,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormatter.formatDate(date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        if (category != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            catName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: catColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Amount formatted in Vietnamese Dong (e.g. 65.000 đ)
              Text(
                CurrencyFormatter.format(amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.tealAccent : const Color(0xFF00695C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
