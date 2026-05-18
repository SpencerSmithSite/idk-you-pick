import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_chooser/services/data_import_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('DataImportService', () {
    test('throws ImportException when schemaVersion is missing', () async {
      expect(
        () => DataImportService.importUserData({}),
        throwsA(isA<ImportException>()),
      );
    });

    test('throws ImportException when schemaVersion is unsupported', () async {
      expect(
        () => DataImportService.importUserData({'schemaVersion': 99}),
        throwsA(isA<ImportException>()),
      );
    });

    test('throws ImportException when schemaVersion is not an int', () async {
      expect(
        () => DataImportService.importUserData({'schemaVersion': '1'}),
        throwsA(isA<ImportException>()),
      );
    });

    test('imports valid data and writes to SharedPreferences', () async {
      final data = {
        'schemaVersion': 1,
        'exportedAt': '2024-01-01T00:00:00.000Z',
        'favorites': ['Taco Bell'],
        'seenHistory': {'Taco Bell': '2024-01-01T12:00:00.000Z'},
        'activeFilters': {
          'cuisines': ['Mexican'],
          'types': ['Fast Food'],
          'prices': [r'$'],
          'maxDistance': 10.0,
        },
        'locationPrefs': {'useLocation': true},
        'notificationSettings': {'lunchtimeSuggestions': false},
      };

      final summary = await DataImportService.importUserData(data);
      expect(summary.favoritesCount, 1);
      expect(summary.historyCount, 1);
      expect(summary.filtersImported, true);
      expect(summary.locationPrefsImported, true);
      expect(summary.notificationSettingsImported, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('restaurant_favorites'), '["Taco Bell"]');
      expect(prefs.getString('restaurant_history'), '{"Taco Bell":"2024-01-01T12:00:00.000Z"}');
      expect(prefs.getStringList('filter_cuisines'), ['Mexican']);
      expect(prefs.getStringList('filter_types'), ['Fast Food']);
      expect(prefs.getStringList('filter_prices'), [r'$']);
      expect(prefs.getDouble('filter_max_distance'), 10.0);
      expect(prefs.getBool('use_location'), true);
      expect(prefs.getBool('lunchtime_suggestions'), false);
    });

    test('handles missing optional fields gracefully', () async {
      final data = {
        'schemaVersion': 1,
        'exportedAt': '2024-01-01T00:00:00.000Z',
      };

      final summary = await DataImportService.importUserData(data);
      expect(summary.favoritesCount, 0);
      expect(summary.historyCount, 0);
      expect(summary.filtersImported, false);
      expect(summary.locationPrefsImported, false);
      expect(summary.notificationSettingsImported, false);
    });
  });
}
