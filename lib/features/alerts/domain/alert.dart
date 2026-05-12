import 'package:cloud_firestore/cloud_firestore.dart';

import '../../incidents/domain/incident_severity.dart';

enum AlertScope {
  all,
  barangay;

  static AlertScope fromName(String? name) {
    return AlertScope.values.firstWhere(
      (s) => s.name == name,
      orElse: () => AlertScope.all,
    );
  }
}

class Alert {
  final String id;
  final String title;
  final String body;
  final IncidentSeverity severity;
  final AlertScope scope;
  final String? barangayId;
  final String issuedBy;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final String? relatedIncidentId;
  final GeoPoint? location;

  const Alert({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.scope,
    required this.issuedBy,
    required this.issuedAt,
    this.barangayId,
    this.expiresAt,
    this.relatedIncidentId,
    this.location,
  });

  factory Alert.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Alert(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      severity: IncidentSeverity.fromName(d['severity'] as String?),
      scope: AlertScope.fromName(d['scope'] as String?),
      barangayId: d['barangayId'] as String?,
      issuedBy: d['issuedBy'] as String? ?? '',
      issuedAt: (d['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (d['expiresAt'] as Timestamp?)?.toDate(),
      relatedIncidentId: d['relatedIncidentId'] as String?,
      location: d['location'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'severity': severity.name,
        'scope': scope.name,
        if (barangayId != null) 'barangayId': barangayId,
        'issuedBy': issuedBy,
        'issuedAt': Timestamp.fromDate(issuedAt),
        if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
        if (relatedIncidentId != null) 'relatedIncidentId': relatedIncidentId,
        if (location != null) 'location': location,
      };

  bool get isActive => expiresAt == null || expiresAt!.isAfter(DateTime.now());
}
