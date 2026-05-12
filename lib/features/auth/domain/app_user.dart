import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String barangayId;
  final String? phone;
  final String? photoURL;
  final List<String> fcmTokens;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.barangayId,
    required this.fcmTokens,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.photoURL,
  });

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: UserRole.fromName(data['role'] as String?),
      barangayId: data['barangayId'] as String? ?? 'unassigned',
      phone: data['phone'] as String?,
      photoURL: data['photoURL'] as String?,
      fcmTokens: List<String>.from(data['fcmTokens'] as List<dynamic>? ?? const []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'barangayId': barangayId,
        'phone': phone,
        'photoURL': photoURL,
        'fcmTokens': fcmTokens,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
