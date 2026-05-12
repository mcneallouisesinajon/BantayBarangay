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
import '../providers/incidents_providers.dart';
import '../widgets/incident_card.dart';

class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return const AppScaffold(
          title: 'My Desk',
          eyebrow: 'YOUR FILED REPORTS',
          body: LoadingView());
    }
    final reports = ref.watch(myIncidentsStreamProvider(user.uid));

    return AppScaffold(
      eyebrow: 'YOUR FILED REPORTS',
      title: 'My Desk',
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('/report'),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('FILE A REPORT'),
        ),
      ],
      body: reports.when(
        loading: () => const LoadingView(),
        error: (e, st) {
          logError('Failed to load my reports', e, st);
          return Center(
            child: ErrorView(
              message: 'We couldn\'t load your reports right now.',
              debugDetails: e,
            ),
          );
        },
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: EmptyView(
                title: 'No reports yet',
                description:
                    'Tap "File a report" to publish your first incident to the desk.',
                icon: Icons.assignment_outlined,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(48, 28, 48, 48),
            itemCount: list.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    children: [
                      Text(
                          '${list.length.toString().padLeft(2, '0')} REPORT${list.length == 1 ? '' : 'S'} ON FILE',
                          style:
                              TereTheme.overline(size: 11, color: TereTheme.ink)),
                      const SizedBox(width: 12),
                      const Expanded(
                          child: Divider(
                              thickness: 2,
                              color: TereTheme.ink,
                              height: 2)),
                    ],
                  ),
                );
              }
              final report = list[i - 1];
              return IncidentCard(
                incident: report,
                onTap: () => context.go('/incident/${report.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
