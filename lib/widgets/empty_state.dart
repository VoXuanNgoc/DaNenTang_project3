import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.receipt_long_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(8),
              ),
              child: Icon(
                icon,
                size: 56,
                color: isDark ? Colors.tealAccent : const Color(0xFF00695C),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
