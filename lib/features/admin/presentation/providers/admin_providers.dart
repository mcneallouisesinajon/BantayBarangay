import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/app_user.dart';
import '../../data/admin_repository.dart';

final allUsersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(adminRepositoryProvider).watchUsers();
});
