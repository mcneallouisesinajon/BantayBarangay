import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required.';
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(v.trim())) {
          return 'Enter a valid email address.';
        }
        return null;
      },
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({super.key, required this.controller, this.label = 'Password'});
  final TextEditingController controller;
  final String label;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required.';
        if (v.length < 6) return 'Password must be at least 6 characters.';
        return null;
      },
    );
  }
}
