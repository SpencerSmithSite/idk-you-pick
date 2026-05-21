import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

/// Theme mode preference backed by SharedPreferences.
///
/// Notifies listeners when the theme changes. Supports
/// system, light, and dark modes.
class ThemeProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_theme_mode';
  static const String _hcPrefsKey = 'high_contrast_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _highContrast = false;

  ThemeMode get themeMode => _themeMode;
  bool get highContrast => _highContrast;

  ThemeProvider() {
    _loadPreference();
  }

  /// Load saved preference from SharedPreferences.
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      _themeMode = _parseThemeMode(saved);
    }
    _highContrast = prefs.getBool(_hcPrefsKey) ?? false;
    notifyListeners();
  }

  /// Set theme mode and persist it.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _themeModeToString(mode));
    notifyListeners();
  }

  /// Set high contrast mode and persist it.
  Future<void> setHighContrast(bool enabled) async {
    if (_highContrast == enabled) return;
    _highContrast = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hcPrefsKey, enabled);
    notifyListeners();
  }

  /// Toggle between light and dark (skipping system for quick toggle).
  Future<void> toggle() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  /// Build a ThemeData with the high-contrast extension applied.
  ThemeData lightThemeWithExtension(ThemeData base) {
    return base.copyWith(
      extensions: [HighContrastTheme(enabled: _highContrast)],
    );
  }

  ThemeData darkThemeWithExtension(ThemeData base) {
    return base.copyWith(
      extensions: [HighContrastTheme(enabled: _highContrast)],
    );
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
