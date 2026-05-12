import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_bootstrap.dart';
import '../domain/alert.dart';

class AlertsRepository {
  AlertsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.alertsCollection);

  // Firestore's `whereIn` no longer accepts null, so we run the
  // barangay-specific and global feeds as two separate queries and merge
  // their latest snapshots client-side.
  Stream<List<Alert>> watchForBarangay(String barangayId) {
    final controller = StreamController<List<Alert>>();
    List<Alert> mine = const [];
    List<Alert> global = const [];
    var mineReady = false;
    var globalReady = false;

    void emit() {
      if (!mineReady || !globalReady) return;
      final byId = <String, Alert>{};
      for (final a in mine) {
        byId[a.id] = a;
      }
      for (final a in global) {
        byId[a.id] = a;
      }
      final merged = byId.values.toList()
        ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
      if (!controller.isClosed) {
        controller.add(merged.take(50).toList());
      }
    }

    final mineSub = _col
        .where('barangayId', isEqualTo: barangayId)
        .orderBy('issuedAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (s) {
        mine = s.docs.map(Alert.fromDoc).toList();
        mineReady = true;
        emit();
      },
      onError: (Object e, StackTrace st) {
        if (!controller.isClosed) controller.addError(e, st);
      },
    );

    final globalSub = _col
        .where('scope', isEqualTo: AlertScope.all.name)
        .orderBy('issuedAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (s) {
        global = s.docs.map(Alert.fromDoc).toList();
        globalReady = true;
        emit();
      },
      onError: (Object e, StackTrace st) {
        if (!controller.isClosed) controller.addError(e, st);
      },
    );

    controller.onCancel = () async {
      await mineSub.cancel();
      await globalSub.cancel();
    };

    return controller.stream;
  }

  Stream<List<Alert>> watchAll() {
    return _col
        .orderBy('issuedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(Alert.fromDoc).toList());
  }

  Future<Alert> create(Alert alert) async {
    final doc = _col.doc();
    final created = Alert(
      id: doc.id,
      title: alert.title,
      body: alert.body,
      severity: alert.severity,
      scope: alert.scope,
      barangayId: alert.barangayId,
      issuedBy: alert.issuedBy,
      issuedAt: alert.issuedAt,
      expiresAt: alert.expiresAt,
      relatedIncidentId: alert.relatedIncidentId,
      location: alert.location,
    );
    await doc.set(created.toMap());
    return created;
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository(ref.watch(firestoreProvider));
});
