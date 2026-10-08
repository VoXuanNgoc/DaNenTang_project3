import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themePrefKey = 'user_theme_mode';

  @override
  ThemeMode build() {
    _loadThemeFromPrefs();
    return ThemeMode.system;
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = prefs.getString(_themePrefKey);
      if (modeString == 'light') {
        state = ThemeMode.light;
      } else if (modeString == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themePrefKey,
        mode == ThemeMode.light
            ? 'light'
            : mode == ThemeMode.dark
                ? 'dark'
                : 'system',
      );
    } catch (_) {}
  }
}
