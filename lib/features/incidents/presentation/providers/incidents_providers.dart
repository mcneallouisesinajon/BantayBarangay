import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/incidents_repository.dart';
import '../../domain/incident.dart';

final myIncidentsStreamProvider =
    StreamProvider.family<List<Incident>, String>((ref, reporterId) {
  return ref.watch(incidentsRepositoryProvider).watchByReporter(reporterId);
});

final barangayIncidentsStreamProvider =
    StreamProvider.family<List<Incident>, String>((ref, barangayId) {
  return ref.watch(incidentsRepositoryProvider).watchByBarangay(barangayId);
});

final pendingIncidentsStreamProvider = StreamProvider<List<Incident>>((ref) {
  return ref.watch(incidentsRepositoryProvider).watchPending();
});

final verifiedIncidentsStreamProvider = StreamProvider<List<Incident>>((ref) {
  return ref.watch(incidentsRepositoryProvider).watchVerified();
});

final allIncidentsStreamProvider = StreamProvider<List<Incident>>((ref) {
  return ref.watch(incidentsRepositoryProvider).watchAll();
});

// Count-only providers for the analytics bar. Prefer these over
// `*StreamProvider.length` because the list providers apply server-side
// limits and orderBy filters that would cap or skew the count.
final pendingIncidentsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(incidentsRepositoryProvider).watchPendingCount();
});

final verifiedIncidentsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(incidentsRepositoryProvider).watchVerifiedCount();
});

final totalIncidentsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(incidentsRepositoryProvider).watchTotalCount();
});

final incidentByIdProvider = StreamProvider.family<Incident?, String>((ref, id) {
  return ref.watch(incidentsRepositoryProvider).watchById(id);
});
