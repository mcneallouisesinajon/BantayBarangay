import 'package:flutter/material.dart';

import '../../app/theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: TereTheme.accent,
              backgroundColor: TereTheme.borderSubtle,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!.toUpperCase(),
              style: TereTheme.overline(color: TereTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
