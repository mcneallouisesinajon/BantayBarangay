import 'package:flutter/material.dart';

import '../../app/theme.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title, this.description, this.icon});
  final String title;
  final String? description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NOTHING HERE',
                style: TereTheme.overline(size: 11, color: TereTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon ?? Icons.inbox_outlined, size: 40, color: TereTheme.ink),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TereTheme.headline(size: 30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(width: 56, height: 3, color: TereTheme.accent),
              if (description != null) ...[
                const SizedBox(height: 20),
                Text(
                  description!,
                  style: TereTheme.body(size: 16, color: TereTheme.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
