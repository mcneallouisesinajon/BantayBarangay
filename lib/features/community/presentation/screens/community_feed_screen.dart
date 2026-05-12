import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/announcements_repository.dart';
import '../../domain/announcement.dart';
import '../providers/community_providers.dart';
import '../widgets/reaction_bar.dart';

class CommunityFeedScreen extends ConsumerWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsStreamProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final canPost = user != null;

    return AppScaffold(
      eyebrow: 'COMMUNITY · BULLETIN',
      title: 'The notice board',
      actions: [
        if (canPost)
          FilledButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('NEW POST'),
            onPressed: () => _showComposer(context, ref),
          ),
      ],
      body: announcementsAsync.when(
        loading: () => const LoadingView(),
        error: (e, st) {
          logError('Failed to load announcements', e, st);
          return Center(
            child: ErrorView(
              message: 'We couldn\'t load the notice board right now.',
              debugDetails: e,
            ),
          );
        },
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: EmptyView(
                title: 'No announcements yet',
                description:
                    'Officials will post community updates here. Check back soon.',
                icon: Icons.campaign_outlined,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(48, 28, 48, 48),
            itemCount: list.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    children: [
                      Text(
                          '${list.length.toString().padLeft(2, '0')} ANNOUNCEMENT${list.length == 1 ? '' : 'S'}',
                          style:
                              TereTheme.overline(size: 11, color: TereTheme.ink)),
                      const SizedBox(width: 12),
                      const Expanded(
                          child: Divider(
                              thickness: 2,
                              color: TereTheme.ink,
                              height: 2)),
                    ],
                  ),
                );
              }
              return _AnnouncementCard(announcement: list[i - 1]);
            },
          );
        },
      ),
    );
  }

  void _showComposer(BuildContext context, WidgetRef ref) {
    final titleC = TextEditingController();
    final bodyC = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('NEW ANNOUNCEMENT', style: TereTheme.overline(size: 12)),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Headline',
                  style: TereTheme.overline(size: 11, color: TereTheme.ink)),
              const SizedBox(height: 8),
              TextField(
                controller: titleC,
                decoration:
                    const InputDecoration(hintText: 'Short, clear, scannable'),
              ),
              const SizedBox(height: 16),
              Text('Message',
                  style: TereTheme.overline(size: 11, color: TereTheme.ink)),
              const SizedBox(height: 8),
              TextField(
                controller: bodyC,
                decoration: const InputDecoration(
                    hintText: 'What happened, when, and what to do next.'),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCEL')),
          FilledButton(
            onPressed: () async {
              final user = ref.read(currentUserProvider).valueOrNull;
              if (user == null) return;
              await ref.read(announcementsRepositoryProvider).create(
                    Announcement(
                      id: '',
                      title: titleC.text.trim(),
                      body: bodyC.text.trim(),
                      authorId: user.uid,
                      authorName: user.displayName,
                      barangayId: user.barangayId,
                      pinned: false,
                      reactions: const {},
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('PUBLISH'),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatefulWidget {
  const _AnnouncementCard({required this.announcement});
  final Announcement announcement;

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.announcement;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => context.go('/community/${a.id}'),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: TereTheme.paper,
              border: Border(
                top: BorderSide(
                    color: a.pinned
                        ? TereTheme.accent
                        : (_hover
                            ? TereTheme.accent
                            : TereTheme.borderMedium),
                    width: a.pinned ? 4 : 2),
                right: BorderSide(
                    color:
                        _hover ? TereTheme.accent : TereTheme.borderMedium,
                    width: 2),
                bottom: BorderSide(
                    color:
                        _hover ? TereTheme.accent : TereTheme.borderMedium,
                    width: 2),
                left: BorderSide(
                    color:
                        _hover ? TereTheme.accent : TereTheme.borderMedium,
                    width: 2),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                        a.pinned
                            ? 'PINNED · TOP STORY'
                            : 'ANNOUNCEMENT',
                        style: TereTheme.overline(
                            size: 11,
                            color: a.pinned
                                ? TereTheme.accent
                                : TereTheme.textSecondary)),
                    const Spacer(),
                    if (a.pinned)
                      const Icon(Icons.push_pin,
                          size: 14, color: TereTheme.accent),
                  ],
                ),
                const SizedBox(height: 8),
                Text(a.title, style: TereTheme.subhead(size: 22)),
                const SizedBox(height: 6),
                Text(
                  'BY ${a.authorName.toUpperCase()} · ${DateFormat.yMMMd().add_jm().format(a.createdAt).toUpperCase()}',
                  style: TereTheme.overline(
                      size: 10, color: TereTheme.textTertiary),
                ),
                const SizedBox(height: 12),
                Text(a.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TereTheme.body(size: 15)),
                const SizedBox(height: 14),
                ReactionBar(announcement: a),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
