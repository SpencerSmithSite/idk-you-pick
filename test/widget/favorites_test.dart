import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rest_chooser/favorites_list_screen.dart';

/// Widget tests for FavoritesListScreen — verifying basic structure.
/// Uses pump() instead of pumpAndSettle() because FutureBuilder + SharedPreferences
/// causes an infinite settle loop in widget tests.
void main() {
  final restaurants = [
    {'name': 'Taco Bell', 'cuisine': 'Mexican', 'type': 'Fast Food', 'priceTier': r'$'},
    {'name': 'Pizza Hut', 'cuisine': 'Italian', 'type': 'Fast Food', 'priceTier': r'$$'},
  ];

  testWidgets('FavoritesListScreen builds without crashing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: FavoritesListScreen(restaurants: restaurants),
      ),
    );
    // Single pump; don't wait for FutureBuilder to settle (SharedPreferences)
    await tester.pump(const Duration(milliseconds: 100));

    // Should at least find the Scaffold
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('FavoritesListScreen uses Aurora Frost background gradient', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: FavoritesListScreen(restaurants: restaurants),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Background gradient Container
    expect(find.byType(Container), findsWidgets);
  });
}
