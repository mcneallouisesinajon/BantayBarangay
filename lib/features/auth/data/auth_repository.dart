import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/firebase_bootstrap.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Stream<AppUser?> userDocStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromDoc(doc) : null);
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      throw AppException(_friendlyMessage(e), code: e.code, cause: e);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String barangayId = AppConstants.defaultBarangayId,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AppException('Account creation failed.');
      }
      await user.updateDisplayName(displayName.trim());
      final now = DateTime.now();
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? email.trim(),
        displayName: displayName.trim(),
        role: UserRole.resident,
        barangayId: barangayId,
        fcmTokens: const [],
        createdAt: now,
        updatedAt: now,
      );
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(appUser.toMap());
    } on FirebaseAuthException catch (e) {
      throw AppException(_friendlyMessage(e), code: e.code, cause: e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AppException(_friendlyMessage(e), code: e.code, cause: e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> ensureUserDoc(User firebaseUser) async {
    final ref = _firestore.collection(AppConstants.usersCollection).doc(firebaseUser.uid);
    final snap = await ref.get();
    if (snap.exists) return;
    final now = DateTime.now();
    final appUser = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Resident',
      role: UserRole.resident,
      barangayId: AppConstants.defaultBarangayId,
      fcmTokens: const [],
      createdAt: now,
      updatedAt: now,
    );
    await ref.set(appUser.toMap());
  }

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters).';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});
