import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import 'firebase_bootstrap.dart';

class NotificationService {
  NotificationService(this._messaging, this._firestore);

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> initFor(String uid) async {
    if (!kIsWeb) return;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      logWarn('Notification permission denied.');
      return;
    }

    try {
      final token = await _messaging.getToken(vapidKey: AppConstants.fcmVapidPublicKey);
      if (token != null && token.isNotEmpty) {
        await _persistToken(uid, token);
      }
    } catch (e, st) {
      logError('FCM getToken failed', e, st);
    }

    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) {
      _persistToken(uid, token);
    });

    _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForeground);
  }

  Future<void> _persistToken(String uid, String token) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  void _handleForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    final title = notification.title ?? 'Bantay Barangay Alert';
    final body = notification.body ?? '';
    try {
      if (html.Notification.permission == 'granted') {
        html.Notification(title, body: body);
      }
    } catch (_) {
      // Browser may not support Notification API; fall through to in-app SnackBar.
    }
    final messengerKey = scaffoldMessengerKey;
    final messenger = messengerKey.currentState;
    messenger?.showSnackBar(
      SnackBar(
        content: Text('$title — $body'),
        action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _tokenRefreshSub?.cancel();
  }
}

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    ref.watch(firebaseMessagingProvider),
    ref.watch(firestoreProvider),
  );
});

/// Watches the signed-in user and binds FCM lifecycle to it. Watch this
/// provider once near the app root to keep tokens fresh.
final notificationsBinderProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  final service = ref.read(notificationServiceProvider);
  if (user != null) {
    service.initFor(user.uid);
  }
  ref.onDispose(() => service.dispose());
});
