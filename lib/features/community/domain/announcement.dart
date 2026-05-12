import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final String? barangayId;
  final bool pinned;
  final Map<String, int> reactions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.pinned,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
    this.barangayId,
  });

  factory Announcement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    final raw = (d['reactions'] as Map<String, dynamic>?) ?? const {};
    return Announcement(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      authorId: d['authorId'] as String? ?? '',
      authorName: d['authorName'] as String? ?? 'Official',
      barangayId: d['barangayId'] as String?,
      pinned: d['pinned'] as bool? ?? false,
      reactions: {for (final e in raw.entries) e.key: (e.value as num).toInt()},
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'authorId': authorId,
        'authorName': authorName,
        if (barangayId != null) 'barangayId': barangayId,
        'pinned': pinned,
        'reactions': reactions,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
