import 'package:flutter/material.dart';

import '../../../app/theme.dart';

enum IncidentStatus {
  pending,
  verified,
  inProgress,
  resolved,
  rejected;

  static IncidentStatus fromName(String? name) {
    return IncidentStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => IncidentStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case IncidentStatus.pending:
        return 'Pending';
      case IncidentStatus.verified:
        return 'Verified';
      case IncidentStatus.inProgress:
        return 'In progress';
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case IncidentStatus.pending:
        return TereTheme.textSecondary;
      case IncidentStatus.verified:
        return TereTheme.ink;
      case IncidentStatus.inProgress:
        return TereTheme.warning;
      case IncidentStatus.resolved:
        return TereTheme.success;
      case IncidentStatus.rejected:
        return TereTheme.accent;
    }
  }

  Color get surface {
    switch (this) {
      case IncidentStatus.pending:
        return TereTheme.surface;
      case IncidentStatus.verified:
        return TereTheme.surface;
      case IncidentStatus.inProgress:
        return TereTheme.warningSurface;
      case IncidentStatus.resolved:
        return TereTheme.successSurface;
      case IncidentStatus.rejected:
        return TereTheme.errorSurface;
    }
  }
}
