import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffoldScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffoldScreen({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: isDark ? const Color(0xFF1E2630) : Colors.white,
        elevation: 3,
        indicatorColor: isDark
            ? const Color(0xFF004D40)
            : const Color(0xFFE0F2F1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF00796B)),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner_rounded, color: Color(0xFF00796B)),
            label: 'Quét hóa đơn',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded, color: Color(0xFF00796B)),
            label: 'Báo cáo',
          ),
        ],
      ),
    );
  }
}
