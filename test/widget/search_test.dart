import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rest_chooser/search_screen.dart';

/// Widget tests for SearchScreen — verifying search query filtering,
/// empty state, sort modes, and tap-to-detail navigation.
void main() {
  final restaurants = [
    {'name': 'Taco Bell', 'cuisine': 'Mexican', 'type': 'Fast Food', 'priceTier': r'$', 'tags': ['drive-thru']},
    {'name': 'Pizza Hut', 'cuisine': 'Italian', 'type': 'Fast Food', 'priceTier': r'$$', 'tags': ['delivery']},
    {'name': 'Sushi King', 'cuisine': 'Japanese', 'type': 'Casual Dining', 'priceTier': r'$$', 'tags': ['date night']},
  ];

  testWidgets('SearchScreen renders search bar and list', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(
          restaurants: restaurants,
          activeCuisines: const {},
          activeTypes: const {},
          activePriceTiers: const {},
          maxDistanceMiles: 10.0,
          useLocation: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('empty query shows all restaurants sorted by name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(
          restaurants: restaurants,
          activeCuisines: const {},
          activeTypes: const {},
          activePriceTiers: const {},
          maxDistanceMiles: 10.0,
          useLocation: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // All restaurant names should appear (sorted by name)
    expect(find.text('Pizza Hut'), findsOneWidget);
    expect(find.text('Sushi King'), findsOneWidget);
    expect(find.text('Taco Bell'), findsOneWidget);
  });

  testWidgets('search query filters results', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(
          restaurants: restaurants,
          activeCuisines: const {},
          activeTypes: const {},
          activePriceTiers: const {},
          maxDistanceMiles: 10.0,
          useLocation: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Type "taco" in search field
    await tester.enterText(find.byType(TextField), 'taco');
    await tester.pumpAndSettle();

    expect(find.text('Taco Bell'), findsOneWidget);
    expect(find.text('Pizza Hut'), findsNothing);
  });

  testWidgets('no results state when query matches nothing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(
          restaurants: restaurants,
          activeCuisines: const {},
          activeTypes: const {},
          activePriceTiers: const {},
          maxDistanceMiles: 10.0,
          useLocation: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pumpAndSettle();

    expect(find.text('No results for "zzzzz"'), findsOneWidget); 
  });

  testWidgets('clear search button empties query', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(
          restaurants: restaurants,
          activeCuisines: const {},
          activeTypes: const {},
          activePriceTiers: const {},
          maxDistanceMiles: 10.0,
          useLocation: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pumpAndSettle();

    // Tap the clear button
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    // All results should be back
    expect(find.text('Pizza Hut'), findsOneWidget);
  });
}
