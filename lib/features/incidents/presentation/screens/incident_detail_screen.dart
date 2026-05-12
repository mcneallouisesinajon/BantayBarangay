import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/incidents_repository.dart';
import '../../domain/incident.dart';
import '../../domain/incident_status.dart';
import '../providers/incidents_providers.dart';
import '../widgets/category_chip.dart';
import '../widgets/severity_badge.dart';
import '../widgets/status_pill.dart';

class IncidentDetailScreen extends ConsumerWidget {
  const IncidentDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(incidentByIdProvider(id));
    return AppScaffold(
      eyebrow: 'INCIDENT FILE',
      title: 'Report',
      body: stream.when(
        loading: () => const LoadingView(),
        error: (e, st) {
          logError('Failed to load incident $id', e, st);
          return Center(
            child: ErrorView(
              message: 'We couldn\'t load this report right now.',
              debugDetails: e,
            ),
          );
        },
        data: (incident) {
          if (incident == null) {
            return const Center(
              child: ErrorView(
                message:
                    'This report is no longer available. It may have been removed.',
              ),
            );
          }
          return _DetailBody(incident: incident);
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final canModerate = user?.role.isOfficialOrAdmin ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(48, 32, 48, 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FILE · ${incident.id.toUpperCase().substring(0, incident.id.length.clamp(0, 8))}',
              style: TereTheme.overline(
                  size: 11, color: TereTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(incident.title,
                      style: TereTheme.display(size: 44)),
                ),
                const SizedBox(width: 16),
                SeverityBadge(severity: incident.severity),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 3, width: 96, color: TereTheme.accent),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CategoryChip(category: incident.category),
                StatusPill(status: incident.status),
                Text(
                  DateFormat.yMMMd()
                      .add_jm()
                      .format(incident.createdAt)
                      .toUpperCase(),
                  style: TereTheme.overline(
                      size: 11, color: TereTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TereTheme.surface,
                border: Border.all(color: TereTheme.borderMedium, width: 2),
              ),
              child: Text(incident.description,
                  style: TereTheme.body(size: 17)),
            ),
            if (incident.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('TAGS · ${incident.tags.join(' · ').toUpperCase()}',
                  style: TereTheme.overline(
                      size: 11, color: TereTheme.textSecondary)),
            ],
            if (incident.address != null && incident.address!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 18, color: TereTheme.ink),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(incident.address!,
                        style: TereTheme.body(size: 15)),
                  ),
                ],
              ),
            ],
            if (incident.location != null) ...[
              const SizedBox(height: 6),
              Text(
                'GPS ${incident.location!.latitude.toStringAsFixed(5)}, ${incident.location!.longitude.toStringAsFixed(5)}',
                style: TereTheme.overline(
                    size: 10, color: TereTheme.textTertiary),
              ),
            ],
            if (incident.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text('PHOTOGRAPHS',
                  style: TereTheme.overline(size: 11, color: TereTheme.ink)),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: incident.photoUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: TereTheme.ink, width: 2),
                    ),
                    child: Image.network(incident.photoUrls[i],
                        fit: BoxFit.cover, width: 240),
                  ),
                ),
              ),
            ],
            if (canModerate) ...[
              const SizedBox(height: 32),
              const Divider(thickness: 2, color: TereTheme.ink, height: 2),
              const SizedBox(height: 18),
              Text('OFFICER ACTIONS',
                  style: TereTheme.overline(
                      size: 11, color: TereTheme.accent)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final s in const [
                    IncidentStatus.verified,
                    IncidentStatus.inProgress,
                    IncidentStatus.resolved,
                    IncidentStatus.rejected,
                  ])
                    OutlinedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text('MARK ${s.label.toUpperCase()}'),
                      onPressed: () async {
                        await ref
                            .read(incidentsRepositoryProvider)
                            .updateStatus(
                              id: incident.id,
                              status: s,
                              actorUid: user!.uid,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Marked ${s.label}.')),
                          );
                        }
                      },
                    ),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('RE-CLASSIFY'),
                    onPressed: () async {
                      await ref
                          .read(incidentsRepositoryProvider)
                          .reclassify(incident);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
