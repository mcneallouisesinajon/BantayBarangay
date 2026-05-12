import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/auth_repository.dart';
import '../widgets/auth_form_fields.dart';
import '../widgets/auth_split_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(
            email: _email.text,
            password: _password.text,
          );
      if (mounted) context.go('/home');
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } catch (e, st) {
      logError('Sign in failed', e, st);
      setState(() => _error =
          'We couldn\'t sign you in. Please check your details and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthSplitLayout(
      dek:
          'Report incidents, follow alerts, and read the bulletin from one bold front page.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Sign in.', style: TereTheme.display(size: 56)),
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 64,
                color: TereTheme.accent,
              ),
              const SizedBox(height: 36),
              _FieldLabel('Email'),
              const SizedBox(height: 8),
              EmailField(controller: _email),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _FieldLabel('Password')),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 0),
                      minimumSize: const Size(0, 24),
                    ),
                    onPressed: _busy
                        ? null
                        : () => context.push('/forgot-password'),
                    child: Text('FORGOT?',
                        style: TereTheme.overline(
                            size: 10, color: TereTheme.accent)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PasswordField(controller: _password),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _ErrorPlate(message: _error!),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: TereTheme.paper))
                    : const Text('SIGN IN'),
              ),
              const SizedBox(height: 36),
              const Divider(height: 2, thickness: 2, color: TereTheme.ink),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New reader?",
                      style: TereTheme.body(
                          size: 14, color: TereTheme.textSecondary)),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: _busy ? null : () => context.push('/register'),
                    child: const Text('CREATE AN ACCOUNT'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: TereTheme.overline(size: 11, color: TereTheme.ink));
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
