import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_bootstrap.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/user_role.dart';

class AdminRepository {
  AdminRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Stream<List<AppUser>> watchUsers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((s) => s.docs.map(AppUser.fromDoc).toList());
  }

  Future<void> setUserRole({required String uid, required UserRole role}) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'role': role.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> setUserBarangay({required String uid, required String barangayId}) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'barangayId': barangayId,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(firestoreProvider));
});
