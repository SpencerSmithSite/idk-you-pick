import 'dart:math' show cos, sin, sqrt, asin;
import 'package:geolocator/geolocator.dart';

/// Service to fetch and cache user location.
class LocationService {
  static Position? _lastPosition;

  /// Request permission and get current position (or last known).
  static Future<Position?> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return _lastPosition;
    } catch (e) {
      return _lastPosition;
    }
  }

  /// Return the cached position (may be null).
  static Position? get lastPosition => _lastPosition;

  static double distanceBetween(double lat1, double lon1, double lat2, double lon2) =>
      distanceInMiles(lat1, lon1, lat2, lon2);

  /// Haversine distance in miles between two lat/lng points.
  static double distanceInMiles(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 3958.8; // Earth radius in miles
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * asin(sqrt(a));
    return R * c;
  }

  static double _toRadians(double deg) => deg * (3.1415926535897932 / 180.0);
}