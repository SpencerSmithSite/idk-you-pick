import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'restaurant_favorites';

  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return {};
    try {
      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> addFavorite(String name) async {
    final favorites = await getFavorites();
    favorites.add(name);
    await _save(favorites);
  }

  static Future<void> removeFavorite(String name) async {
    final favorites = await getFavorites();
    favorites.remove(name);
    await _save(favorites);
  }

  static Future<bool> isFavorite(String name) async {
    final favorites = await getFavorites();
    return favorites.contains(name);
  }

  static Future<void> toggleFavorite(String name) async {
    if (await isFavorite(name)) {
      await removeFavorite(name);
    } else {
      await addFavorite(name);
    }
  }

  static Future<void> _save(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(favorites.toList()));
  }
}
