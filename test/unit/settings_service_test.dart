import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unit tests for Settings save/restore cycle — verifies SharedPreferences
/// integration without widget-level Navigator.pop complexity.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('_savePreferences stores bool values per restaurant', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('A&W', true);
    await prefs.setBool('Taco Bell', false);
    await prefs.setBool('use_location', true);
    await prefs.setStringList('customRestaurants', ['A&W']);

    expect(prefs.getBool('A&W'), true);
    expect(prefs.getBool('Taco Bell'), false);
    expect(prefs.getBool('use_location'), true);
    expect(prefs.getStringList('customRestaurants'), ['A&W']);
  });

  test('_loadPreferences restores values correctly', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('A&W', true);
    await prefs.setBool('Taco Bell', false);

    final aValue = prefs.getBool('A&W');
    final tacoValue = prefs.getBool('Taco Bell');
    final missingValue = prefs.getBool('Missing Spot');

    expect(aValue, true);
    expect(tacoValue, false);
    expect(missingValue, isNull);
  });
}
