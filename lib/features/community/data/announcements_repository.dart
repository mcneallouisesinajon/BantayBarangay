import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_bootstrap.dart';
import '../domain/announcement.dart';

class AnnouncementsRepository {
  AnnouncementsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.announcementsCollection);

  Stream<List<Announcement>> watchAll() {
    return _col
        .orderBy('pinned', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(Announcement.fromDoc).toList());
  }

  Stream<Announcement?> watchById(String id) {
    return _col.doc(id).snapshots().map((s) => s.exists ? Announcement.fromDoc(s) : null);
  }

  Future<Announcement> create(Announcement announcement) async {
    final doc = _col.doc();
    final created = Announcement(
      id: doc.id,
      title: announcement.title,
      body: announcement.body,
      authorId: announcement.authorId,
      authorName: announcement.authorName,
      barangayId: announcement.barangayId,
      pinned: announcement.pinned,
      reactions: announcement.reactions,
      createdAt: announcement.createdAt,
      updatedAt: announcement.updatedAt,
    );
    await doc.set(created.toMap());
    return created;
  }

  Future<void> react(String id, String reaction) async {
    await _col.doc(id).update({
      'reactions.$reaction': FieldValue.increment(1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>((ref) {
  return AnnouncementsRepository(ref.watch(firestoreProvider));
});
