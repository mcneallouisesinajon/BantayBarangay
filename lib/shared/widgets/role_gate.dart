import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/user_role.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class RoleGate extends ConsumerWidget {
  const RoleGate({
    super.key,
    required this.allowed,
    required this.child,
    this.fallback,
  });

  final Set<UserRole> allowed;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null || !allowed.contains(user.role)) {
      return fallback ?? const SizedBox.shrink();
    }
    return child;
  }
}
