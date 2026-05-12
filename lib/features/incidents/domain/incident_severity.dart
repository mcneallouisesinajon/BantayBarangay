import 'package:flutter/material.dart';

import '../../../app/theme.dart';

enum IncidentSeverity {
  low,
  moderate,
  high,
  critical;

  static IncidentSeverity fromName(String? name) {
    return IncidentSeverity.values.firstWhere(
      (s) => s.name == name,
      orElse: () => IncidentSeverity.low,
    );
  }

  String get label {
    switch (this) {
      case IncidentSeverity.low:
        return 'Low';
      case IncidentSeverity.moderate:
        return 'Moderate';
      case IncidentSeverity.high:
        return 'High';
      case IncidentSeverity.critical:
        return 'Critical';
    }
  }

  /// Foreground/border colour for the badge.
  Color get color {
    switch (this) {
      case IncidentSeverity.low:
        return TereTheme.success;
      case IncidentSeverity.moderate:
        return TereTheme.warning;
      case IncidentSeverity.high:
        return TereTheme.accent;
      case IncidentSeverity.critical:
        return TereTheme.ink;
    }
  }

  /// Background tint for the badge.
  Color get surface {
    switch (this) {
      case IncidentSeverity.low:
        return TereTheme.successSurface;
      case IncidentSeverity.moderate:
        return TereTheme.warningSurface;
      case IncidentSeverity.high:
        return TereTheme.errorSurface;
      case IncidentSeverity.critical:
        return TereTheme.ink;
    }
  }

  /// Text colour on the badge surface.
  Color get onSurface {
    switch (this) {
      case IncidentSeverity.critical:
        return TereTheme.paper;
      default:
        return color;
    }
  }

  IncidentSeverity escalate() {
    final next = index + 1;
    if (next >= IncidentSeverity.values.length) return this;
    return IncidentSeverity.values[next];
  }

  IncidentSeverity deescalate() {
    final prev = index - 1;
    if (prev < 0) return this;
    return IncidentSeverity.values[prev];
  }
}
