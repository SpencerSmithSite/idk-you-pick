import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../location_service.dart';

/// Service to pick a random nearby restaurant for lunch suggestions.
class LunchSuggestionService {
  static const String _historyKey = 'lunch_suggestion_history';

  /// Pick a random eligible restaurant. Returns null if none found.
  ///
  /// Optional [testRestaurants] and [testUserPosition] allow testing
  /// without rootBundle or live location.
  static Future<Map<String, dynamic>?> pickLunchSuggestion({
    List<Map<String, dynamic>>? testRestaurants,
    Position? testUserPosition,
  }) async {
    final restaurants = testRestaurants ?? await _loadRestaurants();
    final prefs = await SharedPreferences.getInstance();
    final history = await _loadHistory(prefs);

    // Load filters
    final activeCuisines =
        (prefs.getStringList('filter_cuisines') ?? []).toSet();
    final activeTypes =
        (prefs.getStringList('filter_types') ?? []).toSet();
    final activePriceTiers =
        (prefs.getStringList('filter_prices') ?? []).toSet();
    final maxDistanceMiles = prefs.getDouble('filter_max_distance') ?? 10.0;
    final useLocation = prefs.getBool('use_location') ?? true;

    Position? userPosition;
    if (testUserPosition != null) {
      userPosition = testUserPosition;
    } else if (useLocation) {
      userPosition = await LocationService.determinePosition();
    }

    // Filter eligible restaurants
    final eligible = restaurants.where((r) {
      final name = r['name'] as String;

      // Preferences filter
      final bool pref = prefs.getBool(name) ?? true;
      if (!pref) return false;

      // Active filters
      if (activeCuisines.isNotEmpty &&
          r['cuisine'] != null &&
          !activeCuisines.contains(r['cuisine'])) {
        return false;
      }
      if (activeTypes.isNotEmpty &&
          r['type'] != null &&
          !activeTypes.contains(r['type'])) {
        return false;
      }
      if (activePriceTiers.isNotEmpty &&
          r['priceTier'] != null &&
          !activePriceTiers.contains(r['priceTier'])) {
        return false;
      }

      // Distance filter
      final double? rLat = (r['lat'] as num?)?.toDouble();
      final double? rLng = (r['lng'] as num?)?.toDouble();
      if (useLocation &&
          userPosition != null &&
          rLat != null &&
          rLng != null) {
        final d = LocationService.distanceInMiles(
          userPosition.latitude,
          userPosition.longitude,
          rLat,
          rLng,
        );
        if (d > maxDistanceMiles) return false;
      }

      // History filter: exclude those suggested in the last 7 days
      if (history.contains(name)) return false;

      return true;
    }).toList();

    if (eligible.isEmpty) {
      return null;
    }

    eligible.shuffle();
    final pick = eligible.first;
    return pick;
  }

  /// Load all restaurants from assets/restaurants.json.
  static Future<List<Map<String, dynamic>>> _loadRestaurants() async {
    final String jsonString = await rootBundle.loadString('assets/restaurants.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .whereType<Map<String, dynamic>>()
        .where((r) => (r['name'] as String?)?.isNotEmpty ?? false)
        .toList();
  }

  /// Load suggestion history as a list of restaurant IDs.
  /// Only IDs with a timestamp within the last 7 days are kept.
  static Future<List<String>> _loadHistory(SharedPreferences prefs) async {
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = (json.decode(raw) as Map).cast<String, dynamic>();
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      final kept = <String>{};
      for (final entry in decoded.entries) {
        final ts = DateTime.tryParse(entry.value as String);
        if (ts != null && ts.isAfter(cutoff)) {
          kept.add(entry.key);
        }
      }
      return kept.toList();
    } catch (_) {
      return [];
    }
  }

  /// Save a suggestion to history.
  static Future<void> recordSuggestion(String restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    final Map<String, dynamic> history =
        (raw != null && raw.isNotEmpty) ? Map<String, dynamic>.from(json.decode(raw)) : {};
    history[restaurantId] = DateTime.now().toIso8601String();
    await prefs.setString(_historyKey, json.encode(history));
  }

  /// Clears all suggestion history.
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
