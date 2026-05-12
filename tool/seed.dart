// Seed script for barangays. Run via:
//   dart run tool/seed.dart
// (Requires you to be logged in via gcloud or to run flutterfire configure first.)
//
// In production, prefer manually creating documents via the Firebase console
// or a Cloud Function. This script is a convenience for local dev.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:tere_system/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;

  final barangays = <String, Map<String, dynamic>>{
    'brgy-1': {
      'name': 'Barangay 1',
      'center': const GeoPoint(14.5995, 120.9842),
      'radiusMeters': 1500,
      'contactNumber': '+63-2-555-0001',
    },
    'brgy-2': {
      'name': 'Barangay 2',
      'center': const GeoPoint(14.6042, 120.9822),
      'radiusMeters': 1200,
      'contactNumber': '+63-2-555-0002',
    },
  };

  for (final entry in barangays.entries) {
    await firestore.collection('barangays').doc(entry.key).set(entry.value);
  }
  // ignore: avoid_print
  print('Seeded ${barangays.length} barangays.');
}
