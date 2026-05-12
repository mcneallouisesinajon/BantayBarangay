import 'package:flutter_test/flutter_test.dart';
import 'package:tere_system/features/incidents/domain/classifier.dart';
import 'package:tere_system/features/incidents/domain/incident_category.dart';
import 'package:tere_system/features/incidents/domain/incident_severity.dart';

void main() {
  group('classifyIncident', () {
    test('fire + trapped escalates to critical and picks structure_fire', () {
      final r = classifyIncident(
        title: 'House on fire',
        description: 'A family is trapped inside the building, smoke everywhere.',
        category: IncidentCategory.fire,
      );
      expect(r.severity, IncidentSeverity.critical);
      expect(r.type, 'structure_fire');
      expect(r.tags, contains('trapped'));
    });

    test('vehicle fire stays moderate with no escalation tokens', () {
      final r = classifyIncident(
        title: 'Motorcycle on fire',
        description: 'A motorcycle caught fire by the roadside.',
        category: IncidentCategory.fire,
      );
      expect(r.severity, IncidentSeverity.moderate);
      expect(r.type, 'vehicle_fire');
    });

    test('grass fire de-escalates to low when small/controlled', () {
      final r = classifyIncident(
        title: 'Vacant lot fire',
        description: 'A small grass fire in a vacant lot, controlled by residents.',
        category: IncidentCategory.fire,
      );
      expect(r.severity, IncidentSeverity.low);
      expect(r.type, 'grass_fire');
    });

    test('cardiac stays critical', () {
      final r = classifyIncident(
        title: 'Chest pain',
        description: 'Elderly man clutching his chest, heart attack suspected.',
        category: IncidentCategory.medical,
      );
      expect(r.severity, IncidentSeverity.critical);
      expect(r.type, 'cardiac');
    });

    test('respiratory cannot breathe escalates', () {
      final r = classifyIncident(
        title: 'Asthma attack',
        description: 'Child cannot breathe, wheezing badly.',
        category: IncidentCategory.medical,
      );
      expect(r.severity.index, greaterThanOrEqualTo(IncidentSeverity.high.index));
    });

    test('illness with deescalator drops one level', () {
      final r = classifyIncident(
        title: 'Fever',
        description: 'Minor fever, no other symptoms.',
        category: IncidentCategory.medical,
      );
      expect(r.severity, IncidentSeverity.low);
      expect(r.type, 'illness');
    });

    test('robbery + armed escalates', () {
      final r = classifyIncident(
        title: 'Hold-up at store',
        description: 'Armed robbery with a knife, multiple suspects.',
        category: IncidentCategory.crime,
      );
      expect(r.severity, IncidentSeverity.critical);
      expect(r.type, 'robbery');
    });

    test('theft of phone is moderate', () {
      final r = classifyIncident(
        title: 'Stolen phone',
        description: 'Phone was stolen from the cafe.',
        category: IncidentCategory.crime,
      );
      expect(r.severity, IncidentSeverity.moderate);
      expect(r.type, 'theft');
    });

    test('flash flood with rising water escalates to critical', () {
      final r = classifyIncident(
        title: 'Flash flood',
        description: 'Water rising fast on the street, multiple homes affected.',
        category: IncidentCategory.flood,
      );
      expect(r.severity, IncidentSeverity.critical);
      expect(r.type, 'flash_flood');
    });

    test('drainage clog stays low', () {
      final r = classifyIncident(
        title: 'Clogged drainage',
        description: 'The drainage canal is blocked again.',
        category: IncidentCategory.flood,
      );
      expect(r.severity, IncidentSeverity.low);
      expect(r.type, 'drainage');
    });

    test('vehicular collision picks vehicular_collision', () {
      final r = classifyIncident(
        title: 'Car crash',
        description: 'Two cars rammed each other at the intersection.',
        category: IncidentCategory.accident,
      );
      expect(r.type, 'vehicular_collision');
      expect(r.severity.index, greaterThanOrEqualTo(IncidentSeverity.high.index));
    });

    test('false alarm de-escalates fire baseline', () {
      final r = classifyIncident(
        title: 'Fire false alarm',
        description: 'A false alarm — no fire after all.',
        category: IncidentCategory.fire,
      );
      expect(r.severity.index, lessThanOrEqualTo(IncidentSeverity.high.index));
    });

    test('out of control bigram escalates', () {
      final r = classifyIncident(
        title: 'Fire',
        description: 'The fire is out of control near the houses.',
        category: IncidentCategory.fire,
      );
      expect(r.severity, IncidentSeverity.critical);
    });

    test('unknown text falls back to category default', () {
      final r = classifyIncident(
        title: 'Something happened',
        description: 'A vague description with no clue.',
        category: IncidentCategory.other,
      );
      expect(r.severity, IncidentSeverity.low);
      expect(r.type, 'general');
    });
  });
}
