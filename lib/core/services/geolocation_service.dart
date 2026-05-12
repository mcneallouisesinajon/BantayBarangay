import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class GeolocationService {
  Future<Position?> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }

  GeoPoint? toGeoPoint(Position? position) {
    if (position == null) return null;
    return GeoPoint(position.latitude, position.longitude);
  }
}

final geolocationServiceProvider = Provider<GeolocationService>((ref) => GeolocationService());

final currentPositionProvider = FutureProvider<Position?>((ref) async {
  return ref.watch(geolocationServiceProvider).getCurrentPosition();
});
