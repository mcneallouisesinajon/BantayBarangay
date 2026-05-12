import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../domain/incident_category.dart';
import '../providers/report_form_controller.dart';
import '../widgets/photo_picker_web.dart';

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() =>
      _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  IncidentCategory _category = IncidentCategory.other;
  List<XFile> _photos = const [];

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final incident =
          await ref.read(reportFormControllerProvider.notifier).submit(
                title: _title.text,
                description: _description.text,
                category: _category,
                photos: _photos,
                address:
                    _address.text.trim().isEmpty ? null : _address.text.trim(),
              );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Filed as ${incident.severity.label.toUpperCase()} severity.'),
        ),
      );
      context.go('/incident/${incident.id}');
    } catch (e, st) {
      logError('Incident submission failed', e, st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'We couldn\'t file your report right now. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportFormControllerProvider);
    final busy = state.isLoading;
    return AppScaffold(
      eyebrow: 'FILE A REPORT · OFFICIAL DESK',
      title: 'New incident',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(48, 32, 48, 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('THE LEDGER · INTAKE',
                    style: TereTheme.overline(
                        size: 11, color: TereTheme.accent)),
                const SizedBox(height: 10),
                Text('Tell us what happened.',
                    style: TereTheme.headline(size: 36)),
                const SizedBox(height: 6),
                Container(height: 3, width: 64, color: TereTheme.accent),
                const SizedBox(height: 12),
                Text(
                  'Be specific so officials can triage faster. A clear title and timeline saves minutes when seconds matter.',
                  style: TereTheme.body(
                      size: 15, color: TereTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                _SectionLabel('01 · Category'),
                const SizedBox(height: 8),
                DropdownButtonFormField<IncidentCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(),
                  items: [
                    for (final c in IncidentCategory.values)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon, size: 18, color: TereTheme.ink),
                            const SizedBox(width: 10),
                            Text(c.label,
                                style: TereTheme.body(size: 14)),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(
                      () => _category = v ?? IncidentCategory.other),
                ),
                const SizedBox(height: 22),
                _SectionLabel('02 · Headline'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Flooding at corner of Rizal & Bonifacio',
                  ),
                  validator: (v) => (v == null || v.trim().length < 4)
                      ? 'Enter a short title.'
                      : null,
                ),
                const SizedBox(height: 22),
                _SectionLabel('03 · Story'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(
                    hintText:
                        'What, where, when, and who is affected? Add timeline if you can.',
                  ),
                  maxLines: 6,
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Describe what happened.'
                      : null,
                ),
                const SizedBox(height: 22),
                _SectionLabel('04 · Address (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(
                    hintText: 'Street, landmark, or sitio',
                    helperText:
                        'Your current location is captured automatically when allowed.',
                  ),
                ),
                const SizedBox(height: 22),
                _SectionLabel('05 · Photos (optional)'),
                const SizedBox(height: 8),
                PhotoPickerWeb(onChanged: (files) => _photos = files),
                const SizedBox(height: 32),
                const Divider(thickness: 2, color: TereTheme.ink, height: 2),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Submitting publishes this report to your barangay desk for triage.',
                        style: TereTheme.body(
                            size: 13, color: TereTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: busy ? null : _submit,
                      icon: busy
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: TereTheme.paper))
                          : const Icon(Icons.send, size: 16),
                      label: const Text('FILE REPORT'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: TereTheme.overline(size: 11, color: TereTheme.ink));
  }
}
