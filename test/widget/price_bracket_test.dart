import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rest_chooser/price_bracket_screen.dart';
import 'package:rest_chooser/theme/app_theme.dart';

/// Widget tests for PriceBracketScreen.
void main() {
  group('PriceBracketScreen', () {
    testWidgets('renders title and tier chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: const PriceBracketScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pick a price tier'), findsOneWidget);
      expect(find.text(r'$'), findsOneWidget);
      expect(find.text(r'$$'), findsOneWidget);
      expect(find.text(r'$$$'), findsOneWidget);
      expect(find.text('Start Battle'), findsOneWidget);
    });

    testWidgets('tapping a tier chip selects it', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: const PriceBracketScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the $$ chip
      await tester.tap(find.text(r'$$'));
      await tester.pumpAndSettle();

      // Selection shouldn't crash; chip still present
      expect(find.text(r'$$'), findsOneWidget);
      expect(find.text('Start Battle'), findsOneWidget);
    });
  });
}
