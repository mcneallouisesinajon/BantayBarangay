import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/notification_service.dart';
import 'router.dart';
import 'theme.dart';

class TereApp extends ConsumerWidget {
  const TereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationsBinderProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Bantay Barangay',
      debugShowCheckedModeBanner: false,
      theme: TereTheme.light(),
      darkTheme: TereTheme.dark(),
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: router,
    );
  }
}
