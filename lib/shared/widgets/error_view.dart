import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.debugDetails,
  });
  final String message;
  final VoidCallback? onRetry;
  final Object? debugDetails;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(color: TereTheme.accent),
                child: Text(
                  'ERROR',
                  textAlign: TextAlign.left,
                  style: TereTheme.overline(size: 12, color: TereTheme.paper),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TereTheme.headline(size: 28),
              ),
              const SizedBox(height: 24),
              Container(width: 56, height: 3, color: TereTheme.accent),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: onRetry,
                    child: const Text('TRY AGAIN'),
                  ),
                ),
              ],
              if (kDebugMode && debugDetails != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TereTheme.errorSurface,
                    border: Border.all(color: TereTheme.borderMedium),
                  ),
                  child: Text(
                    '[debug] $debugDetails',
                    style: TereTheme.body(
                        size: 12, color: TereTheme.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
