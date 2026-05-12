import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/alerts_repository.dart';
import '../../domain/alert.dart';

final alertsForBarangayProvider =
    StreamProvider.family<List<Alert>, String>((ref, barangayId) {
  return ref.watch(alertsRepositoryProvider).watchForBarangay(barangayId);
});

final allAlertsStreamProvider = StreamProvider<List<Alert>>((ref) {
  return ref.watch(alertsRepositoryProvider).watchAll();
});
