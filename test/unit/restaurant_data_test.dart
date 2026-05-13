import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Unit tests for restaurant data parsing edge cases.
/// Validates the structure and content of assets/restaurants.json.

void main() {
  late List<dynamic> restaurants;

  setUpAll(() async {
    final file = File('assets/restaurants.json');
    final jsonString = await file.readAsString();
    restaurants = json.decode(jsonString) as List<dynamic>;
  });

  test('all restaurants have required top-level fields', () {
    const requiredFields = <String>{
      'name',
      'cuisine',
      'type',
      'priceTier',
      'lat',
      'lng',
      'tags',
    };
    for (final r in restaurants) {
      final map = r as Map<String, dynamic>;
      for (final field in requiredFields) {
        expect(
          map.containsKey(field),
          isTrue,
          reason: 'Restaurant "${map['name']}" missing field "$field"',
        );
      }
    }
  });

  test('all restaurant names are non-empty unique strings', () {
    final names = <String>{};
    for (final r in restaurants) {
      final map = r as Map<String, dynamic>;
      final name = map['name'];
      expect(name, isA<String>());
      expect(name.toString().trim().isNotEmpty, isTrue);
      expect(
        names.contains(name),
        isFalse,
        reason: 'Duplicate restaurant name: "$name"',
      );
      names.add(name as String);
    }
    expect(names.length, restaurants.length);
  });

  test('lat and lng are valid numbers within reasonable US bounds', () {
    for (final r in restaurants) {
      final map = r as Map<String, dynamic>;
      final lat = map['lat'];
      final lng = map['lng'];
      expect(lat, isA<num>(),
          reason: 'lat for "${map['name']}" is not a number');
      expect(lng, isA<num>(),
          reason: 'lng for "${map['name']}" is not a number');
      expect(lat, greaterThanOrEqualTo(24.0),
          reason: 'lat too low for "${map['name']}"');
      expect(lat, lessThanOrEqualTo(49.0),
          reason: 'lat too high for "${map['name']}"');
      expect(lng, greaterThanOrEqualTo(-125.0),
          reason: 'lng too low for "${map['name']}"');
      expect(lng, lessThanOrEqualTo(-66.0),
          reason: 'lng too high for "${map['name']}"');
    }
  });

  test('cuisine is a known allowed value', () {
    const allowed = <String>{
      'American',
      'Mexican',
      'Pizza',
      'Sandwich',
      'Coffee/Breakfast',
      'Mediterranean',
      'Asian',
    };
    for (final r in restaurants) {
      final map = r as Map<String, dynamic>;
      final cuisine = map['cuisine'];
      expect(
        allowed.contains(cuisine),
        isTrue,
        reason: 'Unknown cuisine "${cuisine ?? 'null'}" for "${map['name']}"',
      );
    }
  });

  test('type is a known allowed value', () {
    const allowed = <String>{
      'Fast Food',
      'Fast Casual',
      'Casual Dining',
    };
    for (final r in restaurants) {
      final map = r as Map<String, dynamic>;
      final type = map['type'];
      expect(
        allowed.contains(type),
        isTrue,
        reason: 'Unknown type "${type ?? 'null'}" for "${map['name']}"',
      );
    }
  });

  test('priceTier is a known allowed value', () {
    const allowed = <String>{
      r'$',
      r'$$',
      r'$$$',
    };
    for (final r in restaurants) {
      final map = r as Map<String, dynamic>;
      final price = map['priceTier'];
      expect(
        allowed.contains(price),
        isTrue,
        reason: 'Unknown priceTier "${price ?? 'null'}" for "${map['name']}"',
      );
    }
  });

  test('tags is a non-empty list of strings', () {
    for (final r in restaurants) {
      final map = r as Map<String, dynamic>;
      final tags = map['tags'];
      expect(tags, isA<List<dynamic>>(),
          reason: 'tags not a list for "${map['name']}"');
      final tagList = tags as List<dynamic>;
      expect(tagList.isNotEmpty, isTrue,
          reason: 'tags empty for "${map['name']}"');
      for (final tag in tagList) {
        expect(tag, isA<String>(),
            reason: 'non-string tag in "${map['name']}"');
        expect(tag.toString().trim().isNotEmpty, isTrue,
            reason: 'empty tag string in "${map['name']}"');
      }
    }
  });

  test('optional fields (website, phone) are either null or non-empty strings',
      () {
    for (final r in restaurants) {
      final map = r as Map<String, dynamic>;
      final website = map['website'];
      final phone = map['phone'];
      if (website != null) {
        expect(website, isA<String>(),
            reason: 'website is not string/null for "${map['name']}"');
        expect(website.toString().trim().isNotEmpty, isTrue,
            reason: 'website is empty string for "${map['name']}"');
      }
      if (phone != null) {
        expect(phone, isA<String>(),
            reason: 'phone is not string/null for "${map['name']}"');
      }
    }
  });

  test('total restaurant count matches expected pool size', () {
    expect(restaurants.length, equals(54));
  });
}
