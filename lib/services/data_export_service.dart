import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Service that exports all user data from SharedPreferences into a
/// serializable map for backup / sharing.
class DataExportService {
  static const int _schemaVersion = 1;

  /// Gather all user data and return it as a Map.
  static Future<Map<String, dynamic>> exportUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Favorites
    final favoritesJson = prefs.getString('restaurant_favorites');
    final List<String> favorites = (favoritesJson != null && favoritesJson.isNotEmpty)
        ? (json.decode(favoritesJson) as List).cast<String>()
        : [];

    // Seen history (restaurant_history)
    final historyJson = prefs.getString('restaurant_history');
    final Map<String, String> seenHistory = {};
    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        final decoded = json.decode(historyJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          seenHistory[entry.key] = entry.value.toString();
        }
      } catch (_) {
        // leave empty on malformed data
      }
    }

    // Active filters
    final activeFilters = <String, dynamic>{};
    final filterCuisines = prefs.getStringList('filter_cuisines');
    final filterTypes = prefs.getStringList('filter_types');
    final filterPrices = prefs.getStringList('filter_prices');
    final maxDistance = prefs.getDouble('filter_max_distance');
    if (filterCuisines != null) activeFilters['cuisines'] = filterCuisines;
    if (filterTypes != null) activeFilters['types'] = filterTypes;
    if (filterPrices != null) activeFilters['prices'] = filterPrices;
    if (maxDistance != null) activeFilters['maxDistance'] = maxDistance;

    // Location preferences
    final locationPrefs = <String, dynamic>{};
    final useLocation = prefs.getBool('use_location');
    if (useLocation != null) locationPrefs['useLocation'] = useLocation;

    // Notification settings
    final notificationSettings = <String, dynamic>{};
    final lunchSuggestions = prefs.getBool('lunchtime_suggestions');
    if (lunchSuggestions != null) {
      notificationSettings['lunchtimeSuggestions'] = lunchSuggestions;
    }

    return {
      'schemaVersion': _schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'favorites': favorites,
      'seenHistory': seenHistory,
      'activeFilters': activeFilters,
      'locationPrefs': locationPrefs,
      'notificationSettings': notificationSettings,
    };
  }
}
