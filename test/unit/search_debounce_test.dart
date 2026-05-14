import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rest_chooser/search_screen.dart';

void main() {
  group('SearchScreen Debounce', () {
    testWidgets('search query is debounced 300ms', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SearchScreen(
            restaurants: [
              {'name': 'Alpha Diner', 'cuisine': 'American', 'type': 'Diner', 'priceTier': r'$', 'tags': ['burgers'], 'lat': 0.0, 'lng': 0.0},
              {'name': 'Beta Bistro', 'cuisine': 'French', 'type': 'Bistro', 'priceTier': r'$$$', 'tags': ['wine'], 'lat': 0.0, 'lng': 0.0},
            ],
            activeCuisines: {},
            activeTypes: {},
            activePriceTiers: {},
            maxDistanceMiles: 100.0,
            useLocation: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Alpha');
      // Immediately expect the old list (both items) because debounce has not fired yet.
      expect(find.text('Alpha Diner'), findsOneWidget);
      expect(find.text('Beta Bistro'), findsOneWidget);

      // Wait for debounce to fire.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      // Only Alpha should remain.
      expect(find.text('Alpha Diner'), findsOneWidget);
      expect(find.text('Beta Bistro'), findsNothing);
    });
  });
}
