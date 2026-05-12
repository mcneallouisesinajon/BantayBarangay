import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/user_role.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/alerts/presentation/screens/alerts_feed_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/broadcast_alert_screen.dart';
import '../features/admin/presentation/screens/users_management_screen.dart';
import '../features/community/presentation/screens/announcement_detail_screen.dart';
import '../features/community/presentation/screens/community_feed_screen.dart';
import '../features/incidents/presentation/screens/incident_detail_screen.dart';
import '../features/incidents/presentation/screens/my_reports_screen.dart';
import '../features/incidents/presentation/screens/report_incident_screen.dart';

const _publicRoutes = {'/login', '/register', '/forgot-password'};

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final userState = ref.read(currentUserProvider);
      final loc = state.uri.path;

      if (authState.isLoading) {
        return loc == '/splash' ? null : '/splash';
      }
      final firebaseUser = authState.valueOrNull;

      if (firebaseUser == null) {
        if (_publicRoutes.contains(loc)) return null;
        return '/login';
      }

      // Authenticated. Wait for user doc stream to settle before deciding.
      if (userState.isLoading) {
        return loc == '/splash' ? null : '/splash';
      }
      final appUser = userState.valueOrNull;

      if (appUser == null) {
        return loc == '/onboarding' ? null : '/onboarding';
      }

      if (_publicRoutes.contains(loc) || loc == '/splash' || loc == '/onboarding') {
        return _homeFor(appUser.role);
      }

      if (loc.startsWith('/admin')) {
        if (!appUser.role.isOfficialOrAdmin) return '/home';
        if (loc.startsWith('/admin/users') && !appUser.role.isAdmin) return '/admin';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

      GoRoute(path: '/home', pageBuilder: (_, __) => _fade(const AlertsFeedScreen())),
      GoRoute(path: '/dashboard', pageBuilder: (_, __) => _fade(const HomeScreen())),

      GoRoute(path: '/report', pageBuilder: (_, __) => _fade(const ReportIncidentScreen())),
      GoRoute(path: '/my-reports', pageBuilder: (_, __) => _fade(const MyReportsScreen())),
      GoRoute(
        path: '/incident/:id',
        pageBuilder: (_, state) => _fade(IncidentDetailScreen(id: state.pathParameters['id']!)),
      ),
      GoRoute(path: '/community', pageBuilder: (_, __) => _fade(const CommunityFeedScreen())),
      GoRoute(
        path: '/community/:id',
        pageBuilder: (_, state) => _fade(AnnouncementDetailScreen(id: state.pathParameters['id']!)),
      ),

      GoRoute(
        path: '/admin',
        pageBuilder: (_, __) => _fade(const AdminDashboardScreen()),
        routes: [
          GoRoute(path: 'incidents', pageBuilder: (_, __) => _fade(const AdminDashboardScreen())),
          GoRoute(
            path: 'incidents/:id',
            pageBuilder: (_, state) => _fade(IncidentDetailScreen(id: state.pathParameters['id']!)),
          ),
          GoRoute(path: 'broadcast', pageBuilder: (_, __) => _fade(const BroadcastAlertScreen())),
          GoRoute(path: 'users', pageBuilder: (_, __) => _fade(const UsersManagementScreen())),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(child: Text('No route for ${state.uri}')),
    ),
  );
});

CustomTransitionPage _fade(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

String _homeFor(UserRole role) {
  // All roles land on the Dashboard. Admins can still navigate to /admin.
  return '/home';
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _authSub = _ref
        .read(authRepositoryProvider)
        .authStateChanges()
        .listen((_) => notifyListeners());
    _userListener = _ref.listen<AsyncValue<Object?>>(
      currentUserProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }

  final Ref _ref;
  StreamSubscription<User?>? _authSub;
  ProviderSubscription<AsyncValue<Object?>>? _userListener;

  @override
  void dispose() {
    _authSub?.cancel();
    _userListener?.close();
    super.dispose();
  }
}
