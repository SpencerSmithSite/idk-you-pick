import 'dart:math' show Random;
import 'package:shared_preferences/shared_preferences.dart';

/// Service that supplies synthetic restaurant data for demo/screenshot mode.
class DemoService {
  static const _key = 'demo_mode_enabled';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  /// Returns a small list of fake rich restaurant objects.
  static List<Map<String, dynamic>> generateFakeRestaurants() {
    final cuisines = ['Italian', 'Mexican', 'Asian', 'American', 'BBQ', 'Coffee'];
    final types = ['Dine In', 'Fast Casual', 'Delivery Only'];
    final prices = ['Cheap', 'Mid-range', 'Fine'];
    const cities = ["Downtown", "Uptown", "Midtown", "Old Town", "Eastside"];
    final r = Random(42);
    return List.generate(6, (i) {
      return {
        'name': 'Demo Diner ${String.fromCharCode(65 + i)}',
        'cuisine': cuisines[i % cuisines.length],
        'type': types[i % types.length],
        'priceTier': prices[i % prices.length],
        'tags': ['Trending', 'New'],
        'lat': 35.2271 + (r.nextDouble() - 0.5) * 0.04,
        'lng': -80.8431 + (r.nextDouble() - 0.5) * 0.04,
        'city': cities[i % cities.length],
        'phone': '(555) 010${10 + i}',
        'website': i.isEven ? 'https://example.com/diner${String.fromCharCode(65 + i)}' : null,
      };
    });
  }
}
