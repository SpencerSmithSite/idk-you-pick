import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_chooser/services/data_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('DataExportService.exportUserData', () {
    test('returns non-empty JSON-serializable data with schemaVersion 1', () async {
      final data = await DataExportService.exportUserData();

      expect(data, isNotNull);
      expect(data, isNotEmpty);
      expect(data['schemaVersion'], 1);

      final jsonString = jsonEncode(data);
      expect(jsonString, isNotEmpty);
      expect(jsonString.contains('"schemaVersion":1'), isTrue);
    });

    test('contains favorites list', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('restaurant_favorites', '["Taco Bell","A&W"]');

      final data = await DataExportService.exportUserData();

      expect(data['favorites'], isA<List>());
      expect(data['favorites'], ['Taco Bell', 'A&W']);
    });

    test('contains settings and preferences fields', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_location', true);
      await prefs.setBool('lunchtime_suggestions', false);
      await prefs.setStringList('filter_cuisines', ['Mexican']);
      await prefs.setStringList('filter_types', ['Fast Food']);
      await prefs.setStringList('filter_prices', [r'$']);
      await prefs.setDouble('filter_max_distance', 5.0);

      final data = await DataExportService.exportUserData();

      expect(data['locationPrefs'], isNotEmpty);
      expect(data['locationPrefs']['useLocation'], true);

      expect(data['notificationSettings'], isNotEmpty);
      expect(data['notificationSettings']['lunchtimeSuggestions'], false);

      expect(data['activeFilters'], isNotEmpty);
      expect(data['activeFilters']['cuisines'], ['Mexican']);
      expect(data['activeFilters']['types'], ['Fast Food']);
      expect(data['activeFilters']['prices'], [r'$']);
      expect(data['activeFilters']['maxDistance'], 5.0);
    });

    test('contains history and seen lists', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'restaurant_history',
        '{"Taco Bell":"2024-01-01T12:00:00.000Z","A&W":"2024-06-15T18:30:00.000Z"}',
      );

      final data = await DataExportService.exportUserData();

      expect(data['seenHistory'], isA<Map<String, dynamic>>());
      expect(data['seenHistory'], isNotEmpty);
      expect(data['seenHistory']['Taco Bell'], '2024-01-01T12:00:00.000Z');
      expect(data['seenHistory']['A&W'], '2024-06-15T18:30:00.000Z');
    });
  });
}
