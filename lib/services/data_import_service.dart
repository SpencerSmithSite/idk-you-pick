import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thrown when imported data has an unsupported schema version or is malformed.
class ImportException implements Exception {
  final String message;
  ImportException(this.message);

  @override
  String toString() => 'ImportException: $message';
}

/// Summary of what was written during a successful import.
class ImportSummary {
  final int favoritesCount;
  final int historyCount;
  final bool filtersImported;
  final bool locationPrefsImported;
  final bool notificationSettingsImported;

  const ImportSummary({
    required this.favoritesCount,
    required this.historyCount,
    required this.filtersImported,
    required this.locationPrefsImported,
    required this.notificationSettingsImported,
  });

  @override
  String toString() {
    return 'ImportSummary(favorites: $favoritesCount, history: $historyCount, '
        'filters: $filtersImported, location: $locationPrefsImported, '
        'notifications: $notificationSettingsImported)';
  }
}

/// Service that validates and imports user data back into SharedPreferences.
class DataImportService {
  static const int _supportedSchemaVersion = 1;

  /// Import a user-data map written by [DataExportService.exportUserData].
  ///
  /// Throws [ImportException] if the schema version is missing or unsupported.
  static Future<ImportSummary> importUserData(Map<String, dynamic> data) async {
    final schemaVersion = data['schemaVersion'];
    if (schemaVersion == null) {
      throw ImportException('Missing schemaVersion');
    }
    if (schemaVersion is! int) {
      throw ImportException('schemaVersion must be an int');
    }
    if (schemaVersion != _supportedSchemaVersion) {
      throw ImportException('Unsupported schemaVersion: $schemaVersion');
    }

    final prefs = await SharedPreferences.getInstance();

    int favoritesCount = 0;
    final favorites = data['favorites'];
    if (favorites is List) {
      final list = favorites.whereType<String>().toList();
      await prefs.setString('restaurant_favorites', json.encode(list));
      favoritesCount = list.length;
    }

    int historyCount = 0;
    final seenHistory = data['seenHistory'];
    if (seenHistory is Map) {
      final map = <String, String>{};
      for (final entry in seenHistory.entries) {
        if (entry.key is String) {
          map[entry.key as String] = entry.value.toString();
        }
      }
      await prefs.setString('restaurant_history', json.encode(map));
      historyCount = map.length;
    }

    bool filtersImported = false;
    final activeFilters = data['activeFilters'];
    if (activeFilters is Map) {
      final cuisines = activeFilters['cuisines'];
      if (cuisines is List) {
        await prefs.setStringList(
            'filter_cuisines', cuisines.whereType<String>().toList());
      }
      final types = activeFilters['types'];
      if (types is List) {
        await prefs.setStringList(
            'filter_types', types.whereType<String>().toList());
      }
      final prices = activeFilters['prices'];
      if (prices is List) {
        await prefs.setStringList(
            'filter_prices', prices.whereType<String>().toList());
      }
      final maxDistance = activeFilters['maxDistance'];
      if (maxDistance is num) {
        await prefs.setDouble('filter_max_distance', maxDistance.toDouble());
      }
      filtersImported = true;
    }

    bool locationPrefsImported = false;
    final locationPrefs = data['locationPrefs'];
    if (locationPrefs is Map) {
      final useLocation = locationPrefs['useLocation'];
      if (useLocation is bool) {
        await prefs.setBool('use_location', useLocation);
      }
      locationPrefsImported = true;
    }

    bool notificationSettingsImported = false;
    final notificationSettings = data['notificationSettings'];
    if (notificationSettings is Map) {
      final lunchSuggestions = notificationSettings['lunchtimeSuggestions'];
      if (lunchSuggestions is bool) {
        await prefs.setBool('lunchtime_suggestions', lunchSuggestions);
      }
      notificationSettingsImported = true;
    }

    return ImportSummary(
      favoritesCount: favoritesCount,
      historyCount: historyCount,
      filtersImported: filtersImported,
      locationPrefsImported: locationPrefsImported,
      notificationSettingsImported: notificationSettingsImported,
    );
  }
}
