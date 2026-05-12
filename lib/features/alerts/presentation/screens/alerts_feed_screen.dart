import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../incidents/domain/incident.dart';
import '../../../incidents/presentation/providers/incidents_providers.dart';
import '../../../incidents/presentation/widgets/incident_card.dart';
import '../../domain/alert.dart';
import '../providers/alerts_providers.dart';
import '../widgets/alert_banner.dart';

class AlertsFeedScreen extends ConsumerWidget {
  const AlertsFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return const AppScaffold(
          eyebrow: 'LIVE BULLETIN',
          title: 'Alerts',
          body: LoadingView());
    }
    final alertsAsync = ref.watch(alertsForBarangayProvider(user.barangayId));
    final verifiedAsync = ref.watch(verifiedIncidentsStreamProvider);
    final showStats = user.role.isOfficialOrAdmin;
    final totalCountAsync =
        showStats ? ref.watch(totalIncidentsCountProvider) : null;
    final verifiedCountAsync =
        showStats ? ref.watch(verifiedIncidentsCountProvider) : null;
    final pendingCountAsync =
        showStats ? ref.watch(pendingIncidentsCountProvider) : null;

    return AppScaffold(
      eyebrow: 'LIVE BULLETIN',
      title: 'Alerts',
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('/report'),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('FILE A REPORT'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(48, 28, 48, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showStats) ...[
              _StatsBar(
                total: totalCountAsync!,
                verified: verifiedCountAsync!,
                pending: pendingCountAsync!,
              ),
              const SizedBox(height: 40),
            ],
            _AlertsSection(alertsAsync: alertsAsync),
            const SizedBox(height: 40),
            _VerifiedIncidentsSection(verifiedAsync: verifiedAsync),
          ],
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.total,
    required this.verified,
    required this.pending,
  });

  final AsyncValue<int> total;
  final AsyncValue<int> verified;
  final AsyncValue<int> pending;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(label: 'TOTAL REPORTED', value: total),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(label: 'VERIFIED', value: verified),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(label: 'PENDING', value: pending, accent: true),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final AsyncValue<int> value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final numberColor = accent ? TereTheme.accent : TereTheme.ink;
    return Container(
      decoration: const BoxDecoration(
        color: TereTheme.paper,
        border: Border.fromBorderSide(
          BorderSide(color: TereTheme.ink, width: 2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TereTheme.overline(size: 11)),
          const SizedBox(height: 10),
          value.when(
            data: (n) => Text(
              n.toString().padLeft(2, '0'),
              style: TereTheme.display(size: 48, color: numberColor),
            ),
            loading: () => Text(
              '—',
              style: TereTheme.display(size: 48, color: TereTheme.textTertiary),
            ),
            error: (_, _) => Text(
              '!',
              style: TereTheme.display(size: 48, color: TereTheme.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: TereTheme.overline(size: 11, color: TereTheme.ink)),
        const SizedBox(width: 12),
        const Expanded(
            child: Divider(thickness: 2, color: TereTheme.ink, height: 2)),
      ],
    );
  }
}

class _SectionNote extends StatelessWidget {
  const _SectionNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Text(
        text,
        style: TereTheme.body(size: 14, color: TereTheme.textSecondary),
      ),
    );
  }
}

class _AlertsSection extends StatelessWidget {
  const _AlertsSection({required this.alertsAsync});
  final AsyncValue<List<Alert>> alertsAsync;

  @override
  Widget build(BuildContext context) {
    return alertsAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(label: 'ACTIVE BULLETINS'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (e, st) {
        logError('Failed to load alerts', e, st);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionHeader(label: 'ACTIVE BULLETINS'),
            ErrorView(
              message: 'We couldn\'t load the alerts feed right now.',
              debugDetails: e,
            ),
          ],
        );
      },
      data: (alerts) {
        final active = alerts.where((a) => a.isActive).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              label:
                  '${active.length.toString().padLeft(2, '0')} ACTIVE BULLETIN${active.length == 1 ? '' : 'S'}',
            ),
            const SizedBox(height: 18),
            if (active.isEmpty)
              const _SectionNote(
                text:
                    'No active alerts. You\'ll be notified when officials issue one.',
              )
            else
              for (final a in active) AlertBanner(alert: a),
          ],
        );
      },
    );
  }
}

class _VerifiedIncidentsSection extends StatelessWidget {
  const _VerifiedIncidentsSection({required this.verifiedAsync});
  final AsyncValue<List<Incident>> verifiedAsync;

  @override
  Widget build(BuildContext context) {
    return verifiedAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(label: 'VERIFIED INCIDENTS'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (e, st) {
        logError('Failed to load verified incidents', e, st);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionHeader(label: 'VERIFIED INCIDENTS'),
            ErrorView(
              message: 'We couldn\'t load verified incidents right now.',
              debugDetails: e,
            ),
          ],
        );
      },
      data: (incidents) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              label:
                  '${incidents.length.toString().padLeft(2, '0')} VERIFIED INCIDENT${incidents.length == 1 ? '' : 'S'}',
            ),
            const SizedBox(height: 18),
            if (incidents.isEmpty)
              const _SectionNote(
                text:
                    'Nothing verified yet. Officials post confirmed incidents here so the barangay stays informed.',
              )
            else
              for (final i in incidents)
                IncidentCard(
                  incident: i,
                  onTap: () => context.go('/incident/${i.id}'),
                ),
          ],
        );
      },
    );
  }
}
