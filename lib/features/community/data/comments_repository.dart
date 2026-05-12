import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_bootstrap.dart';
import '../domain/comment.dart';

class CommentsRepository {
  CommentsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _commentsCol(String announcementId) =>
      _firestore
          .collection(AppConstants.announcementsCollection)
          .doc(announcementId)
          .collection(AppConstants.commentsSubcollection);

  Stream<List<Comment>> watch(String announcementId) {
    return _commentsCol(announcementId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map(Comment.fromDoc).toList());
  }

  Future<Comment> add({
    required String announcementId,
    required String authorId,
    required String authorName,
    required String body,
  }) async {
    final doc = _commentsCol(announcementId).doc();
    final comment = Comment(
      id: doc.id,
      authorId: authorId,
      authorName: authorName,
      body: body.trim(),
      createdAt: DateTime.now(),
    );
    await doc.set(comment.toMap());
    return comment;
  }

  Future<void> delete({required String announcementId, required String commentId}) {
    return _commentsCol(announcementId).doc(commentId).delete();
  }
}

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  return CommentsRepository(ref.watch(firestoreProvider));
});
