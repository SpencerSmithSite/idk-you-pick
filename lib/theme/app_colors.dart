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

// NEW (Liquid Glass - CORRECT)
  // Glass surface (very transparent)
  Color get glassSurface => isDark 
      ? Colors.white.withValues(alpha: 0.06) 
      : Colors.black.withValues(alpha: 0.04);

  // Glass edge highlight (refraction)
  Color get glassEdge => isDark
      ? Colors.white.withValues(alpha: 0.15)
      : Colors.white.withValues(alpha: 0.35);

  // Blur levels
  double get glassBlurLight => 12.0;   // Small elements
  double get glassBlurMedium => 25.0;  // Cards, panels
  double get glassBlurHeavy => 45.0;   // Background, overlays

  // Overlay (nearly transparent with heavy blur)
  Color get glassOverlay => isDark
      ? Colors.black.withValues(alpha: 0.12)
      : Colors.white.withValues(alpha: 0.08);


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

  /// Secondary/body text color (semi-transparent, for subtle contexts).
  Color get textSecondary =>
      isDark
          ? const Color.fromRGBO(255, 255, 255, 0.6)
          : const Color.fromRGBO(0, 0, 0, 0.5);

  /// Solid secondary text color for walkthroughs and high-contrast contexts.
  Color get textSecondarySolid =>
      isDark
          ? const Color(0xFFB0C4DE)
          : const Color(0xFF4A5568);

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

  /// Favorite heart icon color (semantic alias for danger).
  Color get favorite => danger;

  /// Success / confirmation color (green).
  Color get success =>
      isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);

  /// Info / distance color (purple).
  Color get info =>
      isDark ? const Color(0xFFA78BFA) : const Color(0xFF8B5CF6);

  /// Neutral gradient for secondary action buttons (call, website).
  List<Color> get neutralGradient =>
      isDark
          ? [const Color(0xFF374151), const Color(0xFF4B5563)]
          : [const Color(0xFF9CA3AF), const Color(0xFFD1D5DB)];

  /// Large icon tint on gradient backgrounds (low opacity white).
  Color get surfaceIcon => chipTextLight.withValues(alpha: 0.3);

  /// Overlay scrim for modals / overlays.
  Color get scrim => const Color.fromRGBO(0, 0, 0, 0.6);

  /// Accent glow color (orange radial glow behind screens).
  Color get accentGlow =>
      isDark
          ? const Color.fromRGBO(249, 115, 22, 0.12)
          : const Color.fromRGBO(249, 115, 22, 0.06);

  /// Light text for icons / foreground on dark backgrounds.
  Color get foregroundOnDark => chipTextLight;

  /// Switch thumb when unselected (slightly dimmed white).
  Color get switchThumbUnselected => chipTextLight.withValues(alpha: 0.7);

  /// Dismissible background (delete swipe) surface color.
  Color get dismissibleBackground => danger.withValues(alpha: 0.3);

  /// Glow orb low-opacity tint.
  Color get glowTint =>
      isDark
          ? const Color.fromRGBO(13, 148, 136, 0.12)
          : const Color.fromRGBO(13, 148, 136, 0.08);

  /// Frosted-glass blur sigma (adapts to brightness).
  double get backdropBlur => isDark ? 16.0 : 12.0;

  /// Frost overlay tint applied on top of the blurred background.
  Color get backdropTint =>
      isDark
          ? const Color.fromRGBO(255, 255, 255, 0.03)
          : const Color.fromRGBO(255, 255, 255, 0.25);

  /// Transparent overlay for modals behind the glass card.
  Color get overlay => const Color.fromRGBO(0, 0, 0, 0.0);

  static AppColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AppColors(brightness);
  }
}
