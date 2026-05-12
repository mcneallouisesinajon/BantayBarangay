import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_bootstrap.dart';
import '../domain/classifier.dart';
import '../domain/incident.dart';
import '../domain/incident_category.dart';
import '../domain/incident_status.dart';
import 'incidents_storage.dart';

class IncidentsRepository {
  IncidentsRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final IncidentsStorage _storage;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.incidentsCollection);

  Future<Incident> create({
    required String reporterId,
    required String reporterName,
    required String title,
    required String description,
    required IncidentCategory category,
    required String barangayId,
    GeoPoint? location,
    String? address,
    List<XFile> photos = const [],
  }) async {
    final classification = classifyIncident(
      title: title,
      description: description,
      category: category,
    );

    final docRef = _col.doc();
    final now = DateTime.now();
    final photoUrls = photos.isEmpty
        ? <String>[]
        : await _storage.uploadPhotos(
            uid: reporterId,
            incidentId: docRef.id,
            files: photos,
          );

    final incident = Incident(
      id: docRef.id,
      reporterId: reporterId,
      reporterName: reporterName,
      title: title.trim(),
      description: description.trim(),
      category: category,
      severity: classification.severity,
      type: classification.type,
      tags: classification.tags,
      status: IncidentStatus.pending,
      location: location,
      address: address,
      barangayId: barangayId,
      photoUrls: photoUrls,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(incident.toMap());
    return incident;
  }

  Stream<List<Incident>> watchByReporter(String reporterId) {
    return _col
        .where('reporterId', isEqualTo: reporterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Incident.fromDoc).toList());
  }

  Stream<List<Incident>> watchByBarangay(String barangayId) {
    return _col
        .where('barangayId', isEqualTo: barangayId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map(Incident.fromDoc).toList());
  }

  Stream<List<Incident>> watchPending() {
    // Sort client-side so the query doesn't require the composite
    // (status, createdAt) index. Pending lists are small.
    return _col
        .where('status', isEqualTo: IncidentStatus.pending.name)
        .snapshots()
        .map((s) {
      final list = s.docs.map(Incident.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<Incident>> watchVerified({int limit = 50}) {
    // Sort + cap client-side so the query doesn't require the composite
    // (status, createdAt) index.
    return _col
        .where('status', isEqualTo: IncidentStatus.verified.name)
        .snapshots()
        .map((s) {
      final list = s.docs.map(Incident.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list.length > limit ? list.sublist(0, limit) : list;
    });
  }

  Stream<List<Incident>> watchAll({int limit = 500}) {
    return _col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(Incident.fromDoc).toList());
  }

  // Lightweight count streams used by the analytics bar. These use simple
  // equality filters (no orderBy, no limit) so they:
  //   - return an accurate count regardless of how many incidents exist,
  //   - don't depend on the (status, createdAt) composite index,
  //   - don't filter out docs missing the createdAt field.
  Stream<int> watchPendingCount() {
    return _col
        .where('status', isEqualTo: IncidentStatus.pending.name)
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> watchVerifiedCount() {
    return _col
        .where('status', isEqualTo: IncidentStatus.verified.name)
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> watchTotalCount() {
    return _col.snapshots().map((s) => s.size);
  }

  Stream<Incident?> watchById(String id) {
    return _col.doc(id).snapshots().map((s) => s.exists ? Incident.fromDoc(s) : null);
  }

  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String actorUid,
    String? resolutionNotes,
  }) async {
    await _col.doc(id).update({
      'status': status.name,
      'verifiedBy': actorUid,
      'verifiedAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      if (resolutionNotes != null) 'resolutionNotes': resolutionNotes,
    });
  }

  Future<void> reclassify(Incident incident) async {
    final result = classifyIncident(
      title: incident.title,
      description: incident.description,
      category: incident.category,
    );
    await _col.doc(incident.id).update({
      'severity': result.severity.name,
      'type': result.type,
      'tags': result.tags,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

final incidentsRepositoryProvider = Provider<IncidentsRepository>((ref) {
  return IncidentsRepository(
    ref.watch(firestoreProvider),
    ref.watch(incidentsStorageProvider),
  );
});
