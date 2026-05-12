import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../alerts/data/alerts_repository.dart';
import '../../../alerts/domain/alert.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../incidents/domain/incident_severity.dart';

class BroadcastAlertScreen extends ConsumerStatefulWidget {
  const BroadcastAlertScreen({super.key});

  @override
  ConsumerState<BroadcastAlertScreen> createState() =>
      _BroadcastAlertScreenState();
}

class _BroadcastAlertScreenState extends ConsumerState<BroadcastAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  IncidentSeverity _severity = IncidentSeverity.high;
  AlertScope _scope = AlertScope.barangay;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(alertsRepositoryProvider).create(
            Alert(
              id: '',
              title: _title.text.trim(),
              body: _body.text.trim(),
              severity: _severity,
              scope: _scope,
              barangayId:
                  _scope == AlertScope.barangay ? user.barangayId : null,
              issuedBy: user.uid,
              issuedAt: DateTime.now(),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert broadcast.')),
      );
      context.go('/admin');
    } catch (e, st) {
      logError('Alert broadcast failed', e, st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'We couldn\'t send the bulletin right now. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      eyebrow: 'NEWSROOM · BROADCAST',
      title: 'Issue a bulletin',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(48, 32, 48, 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('THE LEDGER · ALL POINTS',
                    style: TereTheme.overline(
                        size: 11, color: TereTheme.accent)),
                const SizedBox(height: 10),
                Text('Broadcast.', style: TereTheme.headline(size: 36)),
                Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 3,
                    width: 64,
                    color: TereTheme.accent),
                const SizedBox(height: 14),
                Text(
                  'Bulletins fan out to every subscriber in the selected scope. Make the headline scannable.',
                  style: TereTheme.body(
                      size: 15, color: TereTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                _Label('01 · Headline'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Flash flood warning — Sitio Ilaya',
                  ),
                  validator: (v) => (v == null || v.trim().length < 4)
                      ? 'Enter a title.'
                      : null,
                ),
                const SizedBox(height: 22),
                _Label('02 · Message'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _body,
                  decoration: const InputDecoration(
                    hintText:
                        'What to do, where, and by when. Keep it short and direct.',
                  ),
                  maxLines: 5,
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Enter a message.'
                      : null,
                ),
                const SizedBox(height: 22),
                _Label('03 · Severity'),
                const SizedBox(height: 8),
                DropdownButtonFormField<IncidentSeverity>(
                  initialValue: _severity,
                  decoration: const InputDecoration(),
                  items: [
                    for (final s in IncidentSeverity.values)
                      DropdownMenuItem(
                          value: s,
                          child: Text(s.label,
                              style: TereTheme.body(size: 14))),
                  ],
                  onChanged: (v) => setState(
                      () => _severity = v ?? IncidentSeverity.high),
                ),
                const SizedBox(height: 22),
                _Label('04 · Scope'),
                const SizedBox(height: 8),
                DropdownButtonFormField<AlertScope>(
                  initialValue: _scope,
                  decoration: const InputDecoration(),
                  items: [
                    DropdownMenuItem(
                        value: AlertScope.barangay,
                        child: Text('My barangay only',
                            style: TereTheme.body(size: 14))),
                    DropdownMenuItem(
                        value: AlertScope.all,
                        child: Text('All barangays',
                            style: TereTheme.body(size: 14))),
                  ],
                  onChanged: (v) =>
                      setState(() => _scope = v ?? AlertScope.barangay),
                ),
                const SizedBox(height: 32),
                const Divider(thickness: 2, color: TereTheme.ink, height: 2),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    icon: _busy
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: TereTheme.paper))
                        : const Icon(Icons.campaign, size: 16),
                    label: const Text('PUBLISH BULLETIN'),
                    onPressed: _busy ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: TereTheme.overline(size: 11, color: TereTheme.ink));
  }
}
