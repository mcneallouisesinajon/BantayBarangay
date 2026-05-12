import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String body;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.createdAt,
  });

  factory Comment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Comment(
      id: doc.id,
      authorId: d['authorId'] as String? ?? '',
      authorName: d['authorName'] as String? ?? '',
      body: d['body'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'body': body,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
