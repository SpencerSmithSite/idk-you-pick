import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode preference backed by SharedPreferences.
///
/// Notifies listeners when the theme changes. Supports
/// system, light, and dark modes.
class ThemeProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadPreference();
  }

  /// Load saved preference from SharedPreferences.
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      _themeMode = _parseThemeMode(saved);
      notifyListeners();
    }
  }

  /// Set theme mode and persist it.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _themeModeToString(mode));
    notifyListeners();
  }

  /// Toggle between light and dark (skipping system for quick toggle).
  Future<void> toggle() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  static ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
