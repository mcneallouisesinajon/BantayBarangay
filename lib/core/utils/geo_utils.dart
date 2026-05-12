import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

double haversineMeters(GeoPoint a, GeoPoint b) {
  const earthRadiusMeters = 6371000.0;
  final lat1 = _deg2rad(a.latitude);
  final lat2 = _deg2rad(b.latitude);
  final dLat = _deg2rad(b.latitude - a.latitude);
  final dLon = _deg2rad(b.longitude - a.longitude);
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  return earthRadiusMeters * c;
}

String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

double _deg2rad(double deg) => deg * (math.pi / 180.0);
