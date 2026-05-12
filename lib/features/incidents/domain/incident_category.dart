import 'package:flutter/material.dart';

import 'incident_severity.dart';

enum IncidentCategory {
  fire,
  medical,
  crime,
  flood,
  accident,
  other;

  static IncidentCategory fromName(String? name) {
    return IncidentCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => IncidentCategory.other,
    );
  }

  String get label {
    switch (this) {
      case IncidentCategory.fire:
        return 'Fire';
      case IncidentCategory.medical:
        return 'Medical';
      case IncidentCategory.crime:
        return 'Crime';
      case IncidentCategory.flood:
        return 'Flood';
      case IncidentCategory.accident:
        return 'Accident';
      case IncidentCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case IncidentCategory.fire:
        return Icons.local_fire_department_outlined;
      case IncidentCategory.medical:
        return Icons.medical_services_outlined;
      case IncidentCategory.crime:
        return Icons.report_outlined;
      case IncidentCategory.flood:
        return Icons.water_outlined;
      case IncidentCategory.accident:
        return Icons.directions_car_filled_outlined;
      case IncidentCategory.other:
        return Icons.help_outline;
    }
  }

  IncidentSeverity get defaultSeverity {
    switch (this) {
      case IncidentCategory.fire:
      case IncidentCategory.medical:
        return IncidentSeverity.high;
      case IncidentCategory.crime:
      case IncidentCategory.flood:
      case IncidentCategory.accident:
        return IncidentSeverity.moderate;
      case IncidentCategory.other:
        return IncidentSeverity.low;
    }
  }
}
