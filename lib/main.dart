import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'router/app_router.dart';
import 'state/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If on desktop (Windows/Linux/macOS), initialize SQLite FFI bindings
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    const ProviderScope(
      child: VkuExpenseOcrApp(),
    ),
  );
}

class VkuExpenseOcrApp extends ConsumerWidget {
  const VkuExpenseOcrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
