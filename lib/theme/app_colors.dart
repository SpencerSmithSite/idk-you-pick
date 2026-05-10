import 'package:flutter/material.dart';

/// Aurora Frost color tokens for light and dark modes.
///
/// Access via AppColors.of(context) which resolves the correct
/// palette based on Theme.of(context).brightness.
class AppColors {
  final Brightness brightness;

  AppColors(this.brightness);

  bool get isDark => brightness == Brightness.dark;

  /// Background gradient colors for scaffold bodies.
  List<Color> get backgroundGradient =>
      isDark
          ? [const Color(0xFF0A0F14), const Color(0xFF141E26)]
          : [const Color(0xFFF8FBFC), const Color(0xFFEEF4F6)];

  /// Surface color for glass cards, sheets, app bars.
  Color get surface =>
      isDark
          ? const Color.fromRGBO(20, 30, 40, 0.7)
          : const Color.fromRGBO(255, 255, 255, 0.6);

  /// Border color for glass surfaces.
  Color get surfaceBorder =>
      isDark
          ? const Color.fromRGBO(255, 255, 255, 0.08)
          : const Color.fromRGBO(255, 255, 255, 0.8);

  /// Primary teal.
  Color get primary =>
      isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);

  /// Primary gradient (for buttons, accents).
  List<Color> get primaryGradient =>
      isDark
          ? [const Color(0xFF0D9488), const Color(0xFF2DD4BF)]
          : [const Color(0xFF0D9488), const Color(0xFF14B8A6)];

  /// Secondary coral/orange.
  Color get secondary =>
      isDark ? const Color(0xFFFB923C) : const Color(0xFFF97316);

  /// Secondary gradient.
  List<Color> get secondaryGradient =>
      isDark
          ? [const Color(0xFFF97316), const Color(0xFFFDBA74)]
          : [const Color(0xFFF97316), const Color(0xFFFB923C)];

  /// Primary text color.
  Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A2E);

  /// Secondary/body text color.
  Color get textSecondary =>
      isDark
          ? const Color.fromRGBO(255, 255, 255, 0.6)
          : const Color.fromRGBO(0, 0, 0, 0.5);

  /// Muted/hint text color.
  Color get textMuted =>
      isDark
          ? const Color.fromRGBO(255, 255, 255, 0.35)
          : const Color.fromRGBO(0, 0, 0, 0.35);

  /// Unselected chip background.
  Color get chipDefaultBg =>
      isDark
          ? const Color.fromRGBO(255, 255, 255, 0.04)
          : const Color.fromRGBO(0, 0, 0, 0.04);

  /// Unselected chip border.
  Color get chipDefaultBorder =>
      isDark
          ? const Color.fromRGBO(255, 255, 255, 0.08)
          : const Color.fromRGBO(0, 0, 0, 0.06);

  /// Soft shadow color.
  Color get shadow =>
      isDark
          ? const Color.fromRGBO(0, 0, 0, 0.3)
          : const Color.fromRGBO(0, 0, 0, 0.04);

  /// Danger/clear color.
  Color get danger =>
      isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);

  /// AppBar title text color (matches textPrimary for readability).
  Color get appBarText => textPrimary;

  /// AppBar gradient (teal duo, same in both modes).
  List<Color> get appBarGradient =>
      isDark
          ? [const Color(0xFF0D9488), const Color(0xFF14B8A6)]
          : [const Color(0xFF2FBFAE), const Color(0xFF40E0D0)];

  /// White-ish color used for chips that need white text.
  Color get chipTextLight => const Color(0xFFFFFFFF);

  /// Dark text used on light colored chips/buttons.
  Color get chipTextDark => const Color(0xFF1A1A2E);

  /// Glow orb low-opacity tint.
  Color get glowTint =>
      isDark
          ? const Color.fromRGBO(13, 148, 136, 0.12)
          : const Color.fromRGBO(13, 148, 136, 0.08);

  static AppColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AppColors(brightness);
  }
}
