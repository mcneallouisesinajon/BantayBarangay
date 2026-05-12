import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'app_scaffold.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, this.phase});
  final String title;
  final String? phase;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('IN DEVELOPMENT',
                style: TereTheme.overline(color: TereTheme.accent)),
            const SizedBox(height: 16),
            Text('Coming soon.', style: TereTheme.display(size: 80)),
            const SizedBox(height: 12),
            Container(height: 3, width: 96, color: TereTheme.accent),
            if (phase != null) ...[
              const SizedBox(height: 24),
              Text(phase!, style: TereTheme.body(size: 18, color: TereTheme.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}
