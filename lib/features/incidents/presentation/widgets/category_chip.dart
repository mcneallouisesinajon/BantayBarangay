import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/incident_category.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category});
  final IncidentCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: TereTheme.borderMedium, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 14, color: TereTheme.textPrimary),
          const SizedBox(width: 6),
          Text(
            category.label.toUpperCase(),
            style: TereTheme.overline(size: 11, color: TereTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
