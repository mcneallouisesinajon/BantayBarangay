import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../domain/app_user.dart';

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final repo = ref.watch(authRepositoryProvider);
  return auth.when(
    loading: () => const Stream<AppUser?>.empty(),
    error: (_, __) => Stream<AppUser?>.value(null),
    data: (user) {
      if (user == null) return Stream<AppUser?>.value(null);
      return repo.userDocStream(user.uid);
    },
  );
});
