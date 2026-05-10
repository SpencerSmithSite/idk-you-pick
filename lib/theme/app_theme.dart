import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Aurora Frost ThemeData definitions for light and dark modes.
class AppTheme {
  static ThemeData lightTheme() {
    final colors = AppColors(Brightness.light);
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0D9488),
        secondary: Color(0xFFF97316),
        surface: Colors.white,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF1A1A2E),
        onSurface: Color(0xFF1A1A2E),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colors.appBarText,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          fontFamily: 'Arial',
        ),
        iconTheme: IconThemeData(color: colors.appBarText),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colors.textPrimary),
        bodyMedium: TextStyle(color: colors.textSecondary),
        bodySmall: TextStyle(color: colors.textMuted),
        titleLarge: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: const TextStyle(fontSize: 20),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.chipDefaultBg,
        selectedColor: const Color(0xFFF97316),
        checkmarkColor: const Color(0xFF1A1A2E),
        labelStyle: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.chipDefaultBorder),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFFF97316),
        inactiveTrackColor: colors.chipDefaultBg,
        thumbColor: const Color(0xFFF97316),
        overlayColor: const Color(0xFFF97316).withValues(alpha: 0.12),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFF97316);
          }
          return colors.chipDefaultBg;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFF1A1A2E)),
        side: BorderSide(color: colors.chipDefaultBorder, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2FBFAE),
        hintStyle: const TextStyle(color: Colors.white70),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final colors = AppColors(Brightness.dark);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2DD4BF),
        secondary: Color(0xFFFB923C),
        surface: Color(0xFF141E26),
        error: Color(0xFFF87171),
        onPrimary: Color(0xFF0A0F14),
        onSecondary: Color(0xFF1A1A2E),
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colors.appBarText,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          fontFamily: 'Arial',
        ),
        iconTheme: IconThemeData(color: colors.appBarText),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colors.textPrimary),
        bodyMedium: TextStyle(color: colors.textSecondary),
        bodySmall: TextStyle(color: colors.textMuted),
        titleLarge: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: const TextStyle(fontSize: 20),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.chipDefaultBg,
        selectedColor: const Color(0xFFFB923C),
        checkmarkColor: const Color(0xFF1A1A2E),
        labelStyle: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.chipDefaultBorder),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFFFB923C),
        inactiveTrackColor: colors.chipDefaultBg,
        thumbColor: const Color(0xFFFB923C),
        overlayColor: const Color(0xFFFB923C).withValues(alpha: 0.12),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFFB923C);
          }
          return colors.chipDefaultBg;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFF1A1A2E)),
        side: BorderSide(color: colors.chipDefaultBorder, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B3A3A),
        hintStyle: const TextStyle(color: Colors.white70),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
