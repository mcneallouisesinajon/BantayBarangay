import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/incident_severity.dart';

class SeverityBadge extends StatelessWidget {
  const SeverityBadge({super.key, required this.severity});
  final IncidentSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: severity.surface,
        border: Border.all(color: severity.color, width: 2),
      ),
      child: Text(
        severity.label.toUpperCase(),
        style: TereTheme.overline(size: 11, color: severity.onSurface),
      ),
    );
  }
}
