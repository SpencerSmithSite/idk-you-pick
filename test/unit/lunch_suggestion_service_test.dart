import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rest_chooser/services/lunch_suggestion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LunchSuggestionService.pickLunchSuggestion', () {
    final testRestaurants = <Map<String, dynamic>>[
      {
        'name': 'Taco Bell',
        'cuisine': 'Mexican',
        'type': 'Fast Food',
        'priceTier': r'$',
        'lat': 40.711,
        'lng': -74.01,
      },
      {
        'name': 'The Capital Grille',
        'cuisine': 'American',
        'type': 'Dine-In',
        'priceTier': r'$$$',
        'lat': 40.761,
        'lng': -73.977,
      },
      {
        'name': 'A&W',
        'cuisine': 'American',
        'type': 'Fast Food',
        'priceTier': r'$',
        'lat': 40.685,
        'lng': -74.039,
      },
    ];

    setUp(() async {
      // Use a recent date (yesterday at noon) so Taco Bell is within 7-day
      // window and gets properly excluded by the history prune.
      final yesterdayNoon =
          DateTime.now().subtract(const Duration(days: 1));
      final yesterdayFormatted =
          DateTime(yesterdayNoon.year, yesterdayNoon.month,
                  yesterdayNoon.day, 12, 0, 0)
              .toIso8601String();
      SharedPreferences.setMockInitialValues({
        'lunch_suggestion_history':
            '{"Taco Bell":"$yesterdayFormatted"}',
      });
    });

    test(
        'returns a restaurant when one is within distance and not in history',
        () async {
      // user is right on top of A&W
      final pos = Position(
        latitude: 40.685,
        longitude: -74.039,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('filter_max_distance', 1.0);

      final result = await LunchSuggestionService.pickLunchSuggestion(
        testRestaurants: testRestaurants,
        testUserPosition: pos,
      );

      expect(result, isNotNull);
      // Taco Bell is in history, A&W is at the same position.
      // A&W should be the only eligible restaurant.
      expect(result!['name'], 'A&W');
    });

    test('returns null when no restaurants are within distance radius',
        () async {
      final pos = Position(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final result = await LunchSuggestionService.pickLunchSuggestion(
        testRestaurants: testRestaurants,
        testUserPosition: pos,
      );

      expect(result, isNull);
    });

    test('excludes restaurants in 7-day history', () async {
      // user near Taco Bell and A&W, but Taco Bell is in history
      final pos = Position(
        latitude: 40.698,
        longitude: -74.024,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final result = await LunchSuggestionService.pickLunchSuggestion(
        testRestaurants: testRestaurants,
        testUserPosition: pos,
      );

      // Taco Bell is in history; assert it's not returned.
      expect(result, isNotNull);
      expect(result?['name'], isNot('Taco Bell'));
    });

    test('respects active cuisine filter', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('filter_cuisines', ['Mexican']);
      // Clear history so Taco Bell is eligible
      await LunchSuggestionService.clearHistory();

      // user near Taco Bell and A&W
      final pos = Position(
        latitude: 40.698,
        longitude: -74.024,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final result = await LunchSuggestionService.pickLunchSuggestion(
        testRestaurants: testRestaurants,
        testUserPosition: pos,
      );

      expect(result, isNotNull);
      expect(result!['name'], 'Taco Bell');
    });

    test('returns null when filters exclude everything', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('filter_cuisines', ['Italian']);

      final pos = Position(
        latitude: 40.698,
        longitude: -74.024,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final result = await LunchSuggestionService.pickLunchSuggestion(
        testRestaurants: testRestaurants,
        testUserPosition: pos,
      );

      expect(result, isNull);
    });

    test('respects disabled restaurant preferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('A&W', false);

      final pos = Position(
        latitude: 40.685,
        longitude: -74.039,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final result = await LunchSuggestionService.pickLunchSuggestion(
        testRestaurants: testRestaurants,
        testUserPosition: pos,
      );

      // A&W is disabled; Taco Bell is in history; Capital Grille is ~6 mi away.
      // With default maxDistance of 10 miles, Capital Grille is eligible.
      expect(result, isNotNull);
      expect(result?['name'], isNot('Taco Bell'));
    });
  });
}
