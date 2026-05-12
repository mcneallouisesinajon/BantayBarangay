import 'package:cloud_firestore/cloud_firestore.dart';

import 'incident_category.dart';
import 'incident_severity.dart';
import 'incident_status.dart';

class Incident {
  final String id;
  final String reporterId;
  final String reporterName;
  final String title;
  final String description;
  final IncidentCategory category;
  final IncidentSeverity severity;
  final String type;
  final List<String> tags;
  final IncidentStatus status;
  final GeoPoint? location;
  final String? address;
  final String barangayId;
  final List<String> photoUrls;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Incident({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.type,
    required this.tags,
    required this.status,
    required this.barangayId,
    required this.photoUrls,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.address,
    this.verifiedBy,
    this.verifiedAt,
    this.resolutionNotes,
  });

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Incident(
      id: doc.id,
      reporterId: d['reporterId'] as String? ?? '',
      reporterName: d['reporterName'] as String? ?? '',
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      category: IncidentCategory.fromName(d['category'] as String?),
      severity: IncidentSeverity.fromName(d['severity'] as String?),
      type: d['type'] as String? ?? 'general',
      tags: List<String>.from(d['tags'] as List<dynamic>? ?? const []),
      status: IncidentStatus.fromName(d['status'] as String?),
      location: d['location'] as GeoPoint?,
      address: d['address'] as String?,
      barangayId: d['barangayId'] as String? ?? 'unassigned',
      photoUrls: List<String>.from(d['photoUrls'] as List<dynamic>? ?? const []),
      verifiedBy: d['verifiedBy'] as String?,
      verifiedAt: (d['verifiedAt'] as Timestamp?)?.toDate(),
      resolutionNotes: d['resolutionNotes'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'reporterId': reporterId,
        'reporterName': reporterName,
        'title': title,
        'description': description,
        'category': category.name,
        'severity': severity.name,
        'type': type,
        'tags': tags,
        'status': status.name,
        if (location != null) 'location': location,
        'address': address,
        'barangayId': barangayId,
        'photoUrls': photoUrls,
        'verifiedBy': verifiedBy,
        if (verifiedAt != null) 'verifiedAt': Timestamp.fromDate(verifiedAt!),
        'resolutionNotes': resolutionNotes,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  Incident copyWith({
    IncidentStatus? status,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? resolutionNotes,
    DateTime? updatedAt,
    IncidentSeverity? severity,
    String? type,
    List<String>? tags,
  }) {
    return Incident(
      id: id,
      reporterId: reporterId,
      reporterName: reporterName,
      title: title,
      description: description,
      category: category,
      severity: severity ?? this.severity,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      location: location,
      address: address,
      barangayId: barangayId,
      photoUrls: photoUrls,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
