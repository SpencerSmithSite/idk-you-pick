import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_chooser/services/data_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('DataExportService', () {
    test('exportUserData returns schema version 1 and ISO timestamp', () async {
      final data = await DataExportService.exportUserData();
      expect(data['schemaVersion'], 1);
      expect(data['exportedAt'], isNotNull);
      final ts = DateTime.tryParse(data['exportedAt'] as String);
      expect(ts, isNotNull);
      expect(ts!.isUtc, true);
    });

    test('exportUserData includes empty collections when no data exists', () async {
      final data = await DataExportService.exportUserData();
      expect(data['favorites'], isEmpty);
      expect(data['seenHistory'], isEmpty);
      expect(data['activeFilters'], isEmpty);
      expect(data['locationPrefs'], isEmpty);
      expect(data['notificationSettings'], isEmpty);
    });

    test('exportUserData reads favorites, history, filters, location, and notifications', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('restaurant_favorites', '["Taco Bell","A&W"]');
      await prefs.setString('restaurant_history', '{"Taco Bell":"2024-01-01T12:00:00.000Z"}');
      await prefs.setStringList('filter_cuisines', ['Mexican', 'American']);
      await prefs.setStringList('filter_types', ['Fast Food']);
      await prefs.setStringList('filter_prices', [r'$']);
      await prefs.setDouble('filter_max_distance', 5.0);
      await prefs.setBool('use_location', false);
      await prefs.setBool('lunchtime_suggestions', true);

      final data = await DataExportService.exportUserData();

      expect(data['favorites'], ['Taco Bell', 'A&W']);
      expect(data['seenHistory'], {'Taco Bell': '2024-01-01T12:00:00.000Z'});
      expect(data['activeFilters']['cuisines'], ['Mexican', 'American']);
      expect(data['activeFilters']['types'], ['Fast Food']);
      expect(data['activeFilters']['prices'], [r'$']);
      expect(data['activeFilters']['maxDistance'], 5.0);
      expect(data['locationPrefs']['useLocation'], false);
      expect(data['notificationSettings']['lunchtimeSuggestions'], true);
    });
  });
}
