import 'package:flutter_test/flutter_test.dart';
import 'package:rest_chooser/location_service.dart';

void main() {
  group('Haversine distanceInMiles', () {
    test('same point returns zero', () {
      const lat = 40.7128;
      const lon = -74.0060;
      expect(LocationService.distanceInMiles(lat, lon, lat, lon), 0.0);
    });

    test('NYC to London is roughly 3459 miles', () {
      // NYC 40.7128, -74.0060 -> London 51.5074, -0.1278
      final miles = LocationService.distanceInMiles(
        40.7128, -74.0060,
        51.5074, -0.1278,
      );
      expect(miles, closeTo(3459, 10));
    });

    test('symmetric distance regardless of order', () {
      final aToB = LocationService.distanceInMiles(
        34.0522, -118.2437,  // Los Angeles
        37.7749, -122.4194,  // San Francisco
      );
      final bToA = LocationService.distanceInMiles(
        37.7749, -122.4194,
        34.0522, -118.2437,
      );
      expect(aToB, closeTo(bToA, 0.0001));
    });

    test('distanceBetween alias matches distanceInMiles', () {
      final d1 = LocationService.distanceInMiles(
        33.7490, -84.3880,  // Atlanta
        25.7617, -80.1918,  // Miami
      );
      final d2 = LocationService.distanceBetween(
        33.7490, -84.3880,
        25.7617, -80.1918,
      );
      expect(d1, d2);
    });

    test('short distance is accurate (~1 mile)', () {
      // ~1 degree latitude ~69 miles; small offset ~1 mile
      final miles = LocationService.distanceInMiles(
        33.7490, -84.3880,
        33.7492, -84.3880,
      );
      expect(miles, closeTo(0.0138, 0.001));
    });
  });
}
