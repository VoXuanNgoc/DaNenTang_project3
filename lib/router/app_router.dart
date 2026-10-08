import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/parsers/receipt_parser.dart';
import '../screens/add_expense_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/main_scaffold_screen.dart';
import '../screens/receipt_detail_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/review_screen.dart';
import '../screens/scan_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _dashboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final GlobalKey<NavigatorState> _scanNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'scan');
final GlobalKey<NavigatorState> _reportsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'reports');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffoldScreen(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Dashboard
        StatefulShellBranch(
          navigatorKey: _dashboardNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Tab 2: Scan
        StatefulShellBranch(
          navigatorKey: _scanNavigatorKey,
          routes: [
            GoRoute(
              path: '/scan',
              builder: (context, state) => const ScanScreen(),
            ),
          ],
        ),
        // Tab 3: Reports
        StatefulShellBranch(
          navigatorKey: _reportsNavigatorKey,
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Push routes (outside persistent bottom bar)
    GoRoute(
      path: '/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/review',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final parsed = extra?['parsed'] as ParsedReceipt?;
        final imagePath = extra?['imagePath'] as String?;
        return ReviewScreen(
          parsedReceipt: parsed,
          imagePath: imagePath,
        );
      },
    ),
    GoRoute(
      path: '/expense/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = int.tryParse(idStr ?? '') ?? 0;
        return ReceiptDetailScreen(receiptId: id);
      },
    ),
  ],
);
