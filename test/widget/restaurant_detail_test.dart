import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_chooser/restaurant_detail.dart';
import 'package:rest_chooser/theme/app_theme.dart';

/// Widget tests for RestaurantDetailScreen.
/// Verifies rendering, chips, actions, and favorite toggle.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('RestaurantDetailScreen', () {
    final restaurant = {
      'name': 'Test Bistro',
      'cuisine': 'Italian',
      'type': 'Casual Dining',
      'priceTier': r'$$',
      'address': '123 Main St',
      'phone': '555-1234',
      'website': 'https://example.com',
      'tags': ['pasta', 'wine'],
      'rating': 4.5,
      'hours': {'Mon': '11:00 AM - 10:00 PM'},
    };

    testWidgets('shows restaurant name and chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: RestaurantDetailScreen(restaurant: restaurant),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Bistro'), findsOneWidget);
      expect(find.text('Italian'), findsOneWidget);
      expect(find.text('Casual Dining'), findsOneWidget);
      expect(find.text(r'$$'), findsOneWidget);
    });

    testWidgets('shows address, phone, website', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: RestaurantDetailScreen(restaurant: restaurant),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('123 Main St'), findsOneWidget);
      expect(find.text('555-1234'), findsOneWidget);
      expect(find.textContaining('example.com'), findsOneWidget);
    });

    testWidgets('favorite icon is present and tappable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: RestaurantDetailScreen(restaurant: restaurant),
        ),
      );
      await tester.pumpAndSettle();

      // Favorite icon appears in the app bar actions
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
    });

    testWidgets('back navigation button exists', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: RestaurantDetailScreen(restaurant: restaurant),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Open in Maps and Visit Website buttons render',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: RestaurantDetailScreen(restaurant: restaurant),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Open in Maps'), findsOneWidget);
      expect(find.text('Visit Website'), findsOneWidget);
    });
  });
}
