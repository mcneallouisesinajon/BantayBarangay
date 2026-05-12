import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/auth_repository.dart';
import '../widgets/auth_form_fields.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(_email.text);
      setState(() => _sent = true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } catch (e, st) {
      logError('Password reset failed', e, st);
      setState(() => _error =
          'We couldn\'t send the reset email. Please verify your email address and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TereTheme.paper,
      appBar: AppBar(
        title: Text('RESET ACCESS', style: TereTheme.overline(size: 13)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(height: 2, thickness: 2, color: TereTheme.ink),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('THE LEDGER · ACCESS RECOVERY',
                        style: TereTheme.overline(
                            size: 11, color: TereTheme.accent)),
                    const SizedBox(height: 14),
                    Text('Forgot it?', style: TereTheme.display(size: 56)),
                    Container(
                        margin: const EdgeInsets.only(top: 8),
                        height: 4,
                        width: 64,
                        color: TereTheme.accent),
                    const SizedBox(height: 20),
                    Text(
                      'Enter your account email and we\'ll send a reset link.',
                      style: TereTheme.body(
                          size: 15, color: TereTheme.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    Text('Email',
                        style: TereTheme.overline(
                            size: 11, color: TereTheme.ink)),
                    const SizedBox(height: 8),
                    EmailField(controller: _email),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _ErrorPlate(message: _error!),
                    ],
                    if (_sent) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0FDF4),
                          border: Border(
                              left: BorderSide(
                                  color: TereTheme.success, width: 4)),
                        ),
                        padding:
                            const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SENT',
                                style: TereTheme.overline(
                                    size: 10, color: TereTheme.success)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Check your inbox for the reset link. It may take a minute.',
                                style: TereTheme.body(size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: TereTheme.paper))
                          : const Text('SEND RESET LINK'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/login'),
                      child: const Text('BACK TO SIGN IN'),
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

class _ErrorPlate extends StatelessWidget {
  const _ErrorPlate({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TereTheme.errorSurface,
        border: Border(left: BorderSide(color: TereTheme.accent, width: 4)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ERROR',
              style: TereTheme.overline(size: 10, color: TereTheme.accent)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TereTheme.body(size: 14, color: TereTheme.ink)),
          ),
        ],
      ),
    );
  }
}
