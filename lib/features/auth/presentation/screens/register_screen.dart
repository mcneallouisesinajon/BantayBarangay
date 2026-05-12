import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/auth_repository.dart';
import '../widgets/auth_form_fields.dart';
import '../widgets/auth_split_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
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
      await ref.read(authRepositoryProvider).register(
            email: _email.text,
            password: _password.text,
            displayName: _name.text,
          );
      if (mounted) context.go('/home');
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } catch (e, st) {
      logError('Registration failed', e, st);
      setState(() => _error =
          'We couldn\'t create your account. Please try again in a moment.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthSplitLayout(
      dek:
          'Create a resident account to file reports, follow alerts, and read the bulletin.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('THE LEDGER · NEW SUBSCRIBER',
                  style: TereTheme.overline(
                      size: 11, color: TereTheme.accent)),
              const SizedBox(height: 14),
              Text('Sign up.', style: TereTheme.display(size: 56)),
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 64,
                color: TereTheme.accent,
              ),
              const SizedBox(height: 20),
              Text(
                'A few details and you\'re in. We use this to verify your barangay membership.',
                style: TereTheme.body(size: 15, color: TereTheme.textSecondary),
              ),
              const SizedBox(height: 36),
              _FieldLabel('Full name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'e.g. Maria Santos',
                ),
                autofillHints: const [AutofillHints.name],
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Enter your full name.'
                    : null,
              ),
              const SizedBox(height: 20),
              _FieldLabel('Email'),
              const SizedBox(height: 8),
              EmailField(controller: _email),
              const SizedBox(height: 20),
              _FieldLabel('Password'),
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
                    : const Text('CREATE ACCOUNT'),
              ),
              const SizedBox(height: 32),
              const _OrRule(label: 'OR CONTINUE WITH'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.g_mobiledata, size: 22),
                      label: const Text('GOOGLE'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.facebook, size: 18),
                      label: const Text('FACEBOOK'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              const Divider(height: 2, thickness: 2, color: TereTheme.ink),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already a reader?',
                      style: TereTheme.body(
                          size: 14, color: TereTheme.textSecondary)),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: _busy ? null : () => context.pop(),
                    child: const Text('SIGN IN'),
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

class _OrRule extends StatelessWidget {
  const _OrRule({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
            child: Divider(thickness: 2, color: TereTheme.borderMedium)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(label,
              style: TereTheme.overline(
                  size: 10, color: TereTheme.textSecondary)),
        ),
        const Expanded(
            child: Divider(thickness: 2, color: TereTheme.borderMedium)),
      ],
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
