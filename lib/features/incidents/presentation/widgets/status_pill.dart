import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/incident_status.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.surface,
        border: Border.all(color: status.color, width: 2),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TereTheme.overline(size: 11, color: status.color),
      ),
    );
  }
}
