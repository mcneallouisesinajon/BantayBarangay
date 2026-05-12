import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../domain/incident.dart';
import 'category_chip.dart';
import 'severity_badge.dart';
import 'status_pill.dart';

/// Editorial incident card — sharp rectangle, 2px border, no shadow.
/// Hover paints the border red; tap is handled by the parent.
class IncidentCard extends StatefulWidget {
  const IncidentCard({super.key, required this.incident, this.onTap});
  final Incident incident;
  final VoidCallback? onTap;

  @override
  State<IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends State<IncidentCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final i = widget.incident;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: TereTheme.paper,
              border: Border.all(
                color: _hover ? TereTheme.accent : TereTheme.borderMedium,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('REPORT · ${i.id.substring(0, i.id.length.clamp(0, 4)).toUpperCase()}',
                        style: TereTheme.overline(
                            size: 10, color: TereTheme.textSecondary)),
                    const Spacer(),
                    SeverityBadge(severity: i.severity),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  i.title,
                  style: TereTheme.subhead(size: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(width: 36, height: 2, color: TereTheme.accent),
                const SizedBox(height: 10),
                Text(
                  i.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TereTheme.body(size: 14, color: TereTheme.textSecondary),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CategoryChip(category: i.category),
                    StatusPill(status: i.status),
                    Text(
                      DateFormat.yMMMd().add_jm().format(i.createdAt).toUpperCase(),
                      style: TereTheme.overline(
                          size: 10, color: TereTheme.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
