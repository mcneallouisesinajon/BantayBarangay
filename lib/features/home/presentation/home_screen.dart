import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../alerts/presentation/providers/alerts_providers.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../incidents/presentation/providers/incidents_providers.dart';
import '../../incidents/presentation/widgets/severity_badge.dart';
import '../../incidents/presentation/widgets/status_pill.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final greetingName = (user?.displayName.isNotEmpty ?? false)
        ? user!.displayName
        : 'Resident';
    final today = DateFormat('EEEE · MMMM d, y').format(DateTime.now());

    final myIncidentsAsync = user == null
        ? const AsyncValue.data(<dynamic>[])
        : ref.watch(myIncidentsStreamProvider(user.uid));
    final alertsAsync = user == null
        ? const AsyncValue.data(<dynamic>[])
        : ref.watch(alertsForBarangayProvider(user.barangayId));

    return AppScaffold(
      title: 'The Daily Bulletin',
      eyebrow: today.toUpperCase(),
      actions: [
        IconButton(
          tooltip: 'View alerts',
          icon: const Icon(Icons.notifications_none),
          onPressed: () => context.go('/home'),
        ),
        FilledButton.icon(
          onPressed: () => context.go('/report'),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('FILE A REPORT'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(48, 32, 48, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroByline(name: greetingName),
            const SizedBox(height: 32),
            _SectionRule(label: 'TOP STORIES'),
            const SizedBox(height: 24),
            _TopStoriesRow(
              alertsAsync: alertsAsync,
              myIncidentsAsync: myIncidentsAsync,
            ),
            const SizedBox(height: 48),
            _SectionRule(label: 'YOUR DESK'),
            const SizedBox(height: 24),
            _ActionGrid(),
            const SizedBox(height: 48),
            _SectionRule(label: 'OPINION'),
            const SizedBox(height: 16),
            _PullQuote(),
          ],
        ),
      ),
    );
  }
}

class _HeroByline extends StatelessWidget {
  const _HeroByline({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FROM THE EDITOR',
              style: TereTheme.overline(size: 11, color: TereTheme.textSecondary)),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TereTheme.display(size: 64),
              children: [
                const TextSpan(text: 'Good day, '),
                TextSpan(
                  text: name,
                  style: TereTheme.display(size: 64, color: TereTheme.accent),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              'Every report you file is on the front page of someone\'s safety. '
              'Read the dispatches, check your desk, and keep the barangay informed.',
              style: TereTheme.body(size: 18, color: TereTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionRule extends StatelessWidget {
  const _SectionRule({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: TereTheme.overline(size: 12)),
        const SizedBox(width: 12),
        const Expanded(child: Divider(thickness: 2, color: TereTheme.ink)),
      ],
    );
  }
}

class _TopStoriesRow extends StatelessWidget {
  const _TopStoriesRow({required this.alertsAsync, required this.myIncidentsAsync});

  final AsyncValue<dynamic> alertsAsync;
  final AsyncValue<dynamic> myIncidentsAsync;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final twoCol = c.maxWidth > 880;
      final lead = _LeadStoryCard(alertsAsync: alertsAsync);
      final desk = _DeskDigestCard(myIncidentsAsync: myIncidentsAsync);
      if (!twoCol) {
        return Column(children: [lead, const SizedBox(height: 24), desk]);
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 7, child: lead),
            const SizedBox(width: 24),
            Expanded(flex: 5, child: desk),
          ],
        ),
      );
    });
  }
}

class _LeadStoryCard extends StatelessWidget {
  const _LeadStoryCard({required this.alertsAsync});
  final AsyncValue<dynamic> alertsAsync;

  @override
  Widget build(BuildContext context) {
    final alerts = alertsAsync.maybeWhen(data: (a) => a as List<dynamic>, orElse: () => const []);
    final active = alerts.where((a) => a.isActive == true).toList();
    final hasAlert = active.isNotEmpty;
    final dynamic lead = hasAlert ? active.first : null;

    return InkWell(
      onTap: () => context.go('/home'),
      child: Container(
        decoration: const BoxDecoration(
          color: TereTheme.paper,
          border: Border(
            top: BorderSide(color: TereTheme.accent, width: 6),
            left: BorderSide(color: TereTheme.ink, width: 2),
            right: BorderSide(color: TereTheme.ink, width: 2),
            bottom: BorderSide(color: TereTheme.ink, width: 2),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('FRONT PAGE', style: TereTheme.overline(size: 11, color: TereTheme.accent)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: const BoxDecoration(color: TereTheme.ink),
                  child: Text(hasAlert ? 'ACTIVE' : 'ALL CLEAR',
                      style: TereTheme.overline(size: 10, color: TereTheme.paper)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              hasAlert
                  ? (lead.title as String)
                  : 'No active alerts in your barangay.',
              style: TereTheme.headline(size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              hasAlert
                  ? (lead.body as String)
                  : 'You\'ll be notified the moment officials issue something. In the meantime, browse community updates or file a report.',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TereTheme.body(size: 17, color: TereTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('READ ALL DISPATCHES',
                    style: TereTheme.overline(size: 11, color: TereTheme.ink)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 14, color: TereTheme.ink),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeskDigestCard extends StatelessWidget {
  const _DeskDigestCard({required this.myIncidentsAsync});
  final AsyncValue<dynamic> myIncidentsAsync;

  @override
  Widget build(BuildContext context) {
    final mine = myIncidentsAsync.maybeWhen(data: (a) => a as List<dynamic>, orElse: () => const []);
    final recent = mine.take(3).toList();

    return Container(
      decoration: const BoxDecoration(
        color: TereTheme.surface,
        border: Border.fromBorderSide(BorderSide(color: TereTheme.ink, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR DESK', style: TereTheme.overline(size: 11)),
          const SizedBox(height: 8),
          Text('Reports you\'ve filed', style: TereTheme.headline(size: 22)),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Nothing on file yet. When you submit a report it will appear here, classified by severity.',
                style: TereTheme.body(size: 14, color: TereTheme.textSecondary),
              ),
            )
          else
            for (var i = 0; i < recent.length; i++) ...[
              if (i > 0) const Divider(height: 16, color: TereTheme.borderSubtle),
              _DeskRow(incident: recent[i]),
            ],
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.go('/my-reports'),
            child: const Text('OPEN MY DESK'),
          ),
        ],
      ),
    );
  }
}

class _DeskRow extends StatelessWidget {
  const _DeskRow({required this.incident});
  final dynamic incident;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/incident/${incident.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(incident.title as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TereTheme.body(size: 15, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.MMMd().add_jm().format(incident.createdAt as DateTime),
                    style: TereTheme.caption(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            StatusPill(status: incident.status),
            const SizedBox(width: 8),
            SeverityBadge(severity: incident.severity),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cards = <_FeatureCard>[
      _FeatureCard(
        rubric: 'SECTION · 01',
        title: 'File an incident',
        blurb:
            'Fire, medical, crime, flood, accidents — officials respond fastest when the classifier sees the right keywords.',
        cta: 'BEGIN REPORT',
        ctaIcon: Icons.edit_outlined,
        accentTop: true,
        onTap: () => context.go('/report'),
      ),
      _FeatureCard(
        rubric: 'SECTION · 02',
        title: 'Track your reports',
        blurb:
            'Watch every report you\'ve filed move from pending to verified to resolved on a single page.',
        cta: 'OPEN DESK',
        ctaIcon: Icons.folder_open_outlined,
        onTap: () => context.go('/my-reports'),
      ),
      _FeatureCard(
        rubric: 'SECTION · 03',
        title: 'Read the community',
        blurb:
            'Announcements, reactions, comment threads. The neighbourhood\'s pulse in chronological order.',
        cta: 'JOIN THE THREAD',
        ctaIcon: Icons.forum_outlined,
        onTap: () => context.go('/community'),
      ),
    ];

    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 1100 ? 3 : (c.maxWidth > 720 ? 2 : 1);
      const gap = 24.0;
      final width = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final card in cards)
            SizedBox(width: width, child: card),
        ],
      );
    });
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.rubric,
    required this.title,
    required this.blurb,
    required this.cta,
    required this.ctaIcon,
    required this.onTap,
    this.accentTop = false,
  });

  final String rubric;
  final String title;
  final String blurb;
  final String cta;
  final IconData ctaIcon;
  final VoidCallback onTap;
  final bool accentTop;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _hover ? TereTheme.ink : TereTheme.borderSubtle;
    final topAccent = widget.accentTop
        ? const BorderSide(color: TereTheme.accent, width: 4)
        : BorderSide(color: borderColor, width: 2);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: BoxDecoration(
            color: TereTheme.paper,
            border: Border(
              top: topAccent,
              left: BorderSide(color: borderColor, width: 2),
              right: BorderSide(color: borderColor, width: 2),
              bottom: BorderSide(color: borderColor, width: 2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.rubric, style: TereTheme.overline(size: 11, color: TereTheme.accent)),
              const SizedBox(height: 12),
              Text(widget.title, style: TereTheme.headline(size: 26)),
              const SizedBox(height: 12),
              Text(
                widget.blurb,
                style: TereTheme.body(size: 14, color: TereTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(widget.ctaIcon, size: 14, color: _hover ? TereTheme.accent : TereTheme.ink),
                  const SizedBox(width: 6),
                  Text(
                    widget.cta,
                    style: TereTheme.overline(
                      size: 12,
                      color: _hover ? TereTheme.accent : TereTheme.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PullQuote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: const BoxDecoration(
        color: TereTheme.surfaceRaised,
        border: Border(left: BorderSide(color: TereTheme.accent, width: 4)),
      ),
      child: Text(
        '“A community is only as informed as its slowest dispatch. File early. File often.”',
        style: TereTheme.body(size: 20).copyWith(
          fontStyle: FontStyle.italic,
          height: 1.55,
        ),
      ),
    );
  }
}
