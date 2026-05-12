class AppConstants {
  AppConstants._();

  static const String appName = 'Bantay Barangay';

  static const String usersCollection = 'users';
  static const String incidentsCollection = 'incidents';
  static const String alertsCollection = 'alerts';
  static const String announcementsCollection = 'announcements';
  static const String commentsSubcollection = 'comments';
  static const String barangaysCollection = 'barangays';

  static const String defaultBarangayId = 'unassigned';

  static const int incidentPhotoMaxBytes = 8 * 1024 * 1024;

  // Public Web Push VAPID key from Firebase console > Cloud Messaging > Web configuration.
  // Safe to commit (this is the public half). Replace before running notifications.
  static const String fcmVapidPublicKey = 'REPLACE_WITH_VAPID_PUBLIC_KEY';
}
