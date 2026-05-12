import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../incidents/domain/incident.dart';
import '../../../incidents/presentation/providers/incidents_providers.dart';
import '../widgets/incident_queue_table.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingIncidentsStreamProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return AppScaffold(
      eyebrow: 'NEWSROOM · TRIAGE',
      title: 'Pending queue',
      actions: [
        OutlinedButton.icon(
          icon: const Icon(Icons.campaign_outlined, size: 16),
          label: const Text('BROADCAST'),
          onPressed: () => context.go('/admin/broadcast'),
        ),
        if (user?.role.isAdmin ?? false)
          OutlinedButton.icon(
            icon: const Icon(Icons.manage_accounts_outlined, size: 16),
            label: const Text('USERS'),
            onPressed: () => context.go('/admin/users'),
          ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(48, 28, 48, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QueueSection(pending: pending),
          ],
        ),
      ),
    );
  }
}

class _QueueSection extends StatelessWidget {
  const _QueueSection({required this.pending});

  final AsyncValue<List<Incident>> pending;

  @override
  Widget build(BuildContext context) {
    return pending.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: LoadingView(),
      ),
      error: (e, st) {
        logError('Failed to load pending incidents', e, st);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: ErrorView(
              message: 'We couldn\'t load the pending queue right now.',
              debugDetails: e,
            ),
          ),
        );
      },
      data: (list) {
        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: EmptyView(
                title: 'Queue is clear',
                description:
                    'No pending incidents need verification right now.',
                icon: Icons.check_circle_outline,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                    '${list.length.toString().padLeft(2, '0')} PENDING · AWAITING DESK',
                    style:
                        TereTheme.overline(size: 11, color: TereTheme.accent)),
                const SizedBox(width: 12),
                const Expanded(
                    child: Divider(
                        thickness: 2, color: TereTheme.ink, height: 2)),
              ],
            ),
            const SizedBox(height: 18),
            IncidentQueueTable(incidents: list),
          ],
        );
      },
    );
  }
}
