import 'package:flutter_test/flutter_test.dart';

/// Stand-alone unit tests for restaurant filter logic.
/// These mirror the filtering rules from lib/main.dart `_filteredPool`.

class Restaurant {
  final String name;
  final List<String> cuisine;
  final List<String> type;
  final List<String> price;

  const Restaurant({
    required this.name,
    required this.cuisine,
    required this.type,
    required this.price,
  });
}

List<Restaurant> applyFilters(
  List<Restaurant> pool,
  Set<String> cuisineFilters,
  Set<String> typeFilters,
  Set<String> priceFilters,
) {
  if (cuisineFilters.isEmpty && typeFilters.isEmpty && priceFilters.isEmpty) {
    return pool;
  }
  return pool.where((r) {
    if (cuisineFilters.isNotEmpty &&
        !cuisineFilters.any((c) => r.cuisine.contains(c))) {
      return false;
    }
    if (typeFilters.isNotEmpty &&
        !typeFilters.any((t) => r.type.contains(t))) {
      return false;
    }
    if (priceFilters.isNotEmpty &&
        !priceFilters.any((p) => r.price.contains(p))) {
      return false;
    }
    return true;
  }).toList();
}

void main() {
  const pool = [
    Restaurant(
      name: 'Taco Bell',
      cuisine: ['Mexican'],
      type: ['Fast Food'],
      price: [r'$'],
    ),
    Restaurant(
      name: 'The Capital Grille',
      cuisine: ['American', 'Steakhouse'],
      type: ['Dine-In'],
      price: [r'$$$'],
    ),
    Restaurant(
      name: 'Panda Express',
      cuisine: ['Chinese'],
      type: ['Fast Food', 'Takeout'],
      price: [r'$'],
    ),
    Restaurant(
      name: 'Local Taco',
      cuisine: ['Mexican'],
      type: ['Dine-In', 'Takeout'],
      price: [r'$$'],
    ),
  ];

  test('empty filters returns full pool', () {
    final result = applyFilters(pool, {}, {}, {});
    expect(result.length, pool.length);
  });

  test('cuisine filter narrows to matching restaurants', () {
    final result = applyFilters(pool, {'Mexican'}, {}, {});
    expect(result.length, 2);
    expect(result.map((r) => r.name).toSet(), {'Taco Bell', 'Local Taco'});
  });

  test('type filter narrows to matching restaurants', () {
    final result = applyFilters(pool, {}, {'Fast Food'}, {});
    expect(result.length, 2);
    expect(result.map((r) => r.name).toSet(), {'Taco Bell', 'Panda Express'});
  });

  test('price filter narrows to matching restaurants', () {
    final result = applyFilters(pool, {}, {}, {r'$'});
    expect(result.length, 2);
    expect(result.map((r) => r.name).toSet(), {'Taco Bell', 'Panda Express'});
  });

  test('combined filters intersect correctly', () {
    final result = applyFilters(pool, {'Mexican'}, {'Fast Food'}, {r'$'});
    expect(result.length, 1);
    expect(result.first.name, 'Taco Bell');
  });

  test('over-constrained filters return empty', () {
    final result = applyFilters(pool, {'Mexican'}, {'Dine-In'}, {r'$$$'});
    expect(result.isEmpty, true);
  });

  test('multi-cuisine OR works', () {
    final result = applyFilters(pool, {'Mexican', 'Chinese'}, {}, {});
    expect(result.length, 3);
  });
}
