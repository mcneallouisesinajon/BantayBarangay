import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../data/announcements_repository.dart';
import '../../domain/announcement.dart';

class ReactionBar extends ConsumerWidget {
  const ReactionBar({super.key, required this.announcement});
  final Announcement announcement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in const [
          ('thumbsUp', Icons.thumb_up_alt_outlined, 'LIKE'),
          ('heart', Icons.favorite_border, 'HEART'),
          ('clap', Icons.celebration_outlined, 'CLAP'),
        ])
          _ReactionChip(
            icon: entry.$2,
            label: entry.$3,
            count: announcement.reactions[entry.$1] ?? 0,
            onTap: () => ref
                .read(announcementsRepositoryProvider)
                .react(announcement.id, entry.$1),
          ),
      ],
    );
  }
}

class _ReactionChip extends StatefulWidget {
  const _ReactionChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  State<_ReactionChip> createState() => _ReactionChipState();
}

class _ReactionChipState extends State<_ReactionChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final fg = _hover ? TereTheme.paper : TereTheme.ink;
    final bg = _hover ? TereTheme.ink : TereTheme.paper;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: TereTheme.ink, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: fg),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: TereTheme.overline(size: 10, color: fg)),
              const SizedBox(width: 8),
              Text(widget.count.toString(),
                  style: TereTheme.overline(
                      size: 11,
                      color: _hover ? TereTheme.accent : TereTheme.accent)),
            ],
          ),
        ),
      ),
    );
  }
}
