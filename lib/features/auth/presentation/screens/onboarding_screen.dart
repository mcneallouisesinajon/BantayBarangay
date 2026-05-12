import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/logger.dart';
import '../../data/auth_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _busy = false;

  Future<void> _continue() async {
    setState(() => _busy = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        await ref.read(authRepositoryProvider).ensureUserDoc(user);
      }
      if (mounted) context.go('/home');
    } catch (e, st) {
      logError('Onboarding failed', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'We couldn\'t finish setting up your account. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TereTheme.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('WELCOME EDITION',
                        style: TereTheme.overline(
                            size: 11, color: TereTheme.accent)),
                    const SizedBox(height: 14),
                    Text('Welcome to\nBantay Barangay.',
                        style: TereTheme.display(size: 56)),
                    Container(
                        margin: const EdgeInsets.only(top: 10),
                        height: 4,
                        width: 96,
                        color: TereTheme.accent),
                    const SizedBox(height: 24),
                    Text(
                      'We\'ll set up your resident profile so you can file incidents and receive alerts from your barangay.',
                      style: TereTheme.body(size: 17),
                    ),
                    const SizedBox(height: 32),
                    const _Bullet(
                      index: '01',
                      title: 'File reports',
                      body:
                          'Send photos and details straight to your officials.',
                    ),
                    const _Bullet(
                      index: '02',
                      title: 'Follow alerts',
                      body:
                          'Get real-time bulletins for emergencies in your area.',
                    ),
                    const _Bullet(
                      index: '03',
                      title: 'Read the bulletin',
                      body:
                          'Catch up on announcements and community updates.',
                    ),
                    const SizedBox(height: 36),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: _busy ? null : _continue,
                        icon: _busy
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: TereTheme.paper))
                            : const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('OPEN THE FRONT PAGE'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.index, required this.title, required this.body});

  final String index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(index,
                style: TereTheme.overline(
                    size: 12, color: TereTheme.accent)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TereTheme.subhead(size: 22)),
                const SizedBox(height: 4),
                Text(body,
                    style: TereTheme.body(
                        size: 14, color: TereTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
