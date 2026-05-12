import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/domain/user_role.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/admin_repository.dart';
import '../providers/admin_providers.dart';

class UsersManagementScreen extends ConsumerWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersStreamProvider);
    final me = ref.watch(currentUserProvider).valueOrNull;

    return AppScaffold(
      eyebrow: 'NEWSROOM · SUBSCRIBERS',
      title: 'Users',
      body: users.when(
        loading: () => const LoadingView(),
        error: (e, st) {
          logError('Failed to load users', e, st);
          return Center(
            child: ErrorView(
              message: 'We couldn\'t load the resident list right now.',
              debugDetails: e,
            ),
          );
        },
        data: (list) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(48, 28, 48, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                        '${list.length.toString().padLeft(2, '0')} REGISTERED RESIDENTS',
                        style: TereTheme.overline(
                            size: 11, color: TereTheme.ink)),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Divider(
                            thickness: 2, color: TereTheme.ink, height: 2)),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: TereTheme.paper,
                    border: Border.all(color: TereTheme.ink, width: 2),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      horizontalMargin: 20,
                      columnSpacing: 32,
                      headingRowHeight: 44,
                      columns: [
                        DataColumn(
                            label: Text('NAME',
                                style: TereTheme.overline(size: 11))),
                        DataColumn(
                            label: Text('EMAIL',
                                style: TereTheme.overline(size: 11))),
                        DataColumn(
                            label: Text('ROLE',
                                style: TereTheme.overline(size: 11))),
                        DataColumn(
                            label: Text('BARANGAY',
                                style: TereTheme.overline(size: 11))),
                      ],
                      rows: [
                        for (final u in list)
                          DataRow(cells: [
                            DataCell(Text(u.displayName,
                                style: TereTheme.body(
                                    size: 14, weight: FontWeight.w700))),
                            DataCell(Text(u.email,
                                style: TereTheme.body(
                                    size: 13,
                                    color: TereTheme.textSecondary))),
                            DataCell(
                              DropdownButton<UserRole>(
                                value: u.role,
                                underline: const SizedBox.shrink(),
                                style: TereTheme.overline(
                                    size: 11, color: TereTheme.ink),
                                onChanged: (u.uid == me?.uid)
                                    ? null
                                    : (newRole) async {
                                        if (newRole == null) return;
                                        await ref
                                            .read(adminRepositoryProvider)
                                            .setUserRole(
                                              uid: u.uid,
                                              role: newRole,
                                            );
                                      },
                                items: [
                                  for (final r in UserRole.values)
                                    DropdownMenuItem(
                                        value: r,
                                        child: Text(r.name.toUpperCase())),
                                ],
                              ),
                            ),
                            DataCell(Text(u.barangayId,
                                style: TereTheme.overline(
                                    size: 11,
                                    color: TereTheme.textSecondary))),
                          ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
