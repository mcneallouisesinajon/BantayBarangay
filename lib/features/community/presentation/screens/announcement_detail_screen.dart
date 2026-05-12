import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../core/utils/logger.dart';
import '../providers/community_providers.dart';
import '../widgets/comment_thread.dart';
import '../widgets/reaction_bar.dart';

class AnnouncementDetailScreen extends ConsumerWidget {
  const AnnouncementDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementAsync = ref.watch(announcementByIdProvider(id));
    return AppScaffold(
      eyebrow: 'COMMUNITY · ARTICLE',
      title: 'Announcement',
      body: announcementAsync.when(
        loading: () => const LoadingView(),
        error: (e, st) {
          logError('Failed to load announcement $id', e, st);
          return Center(
            child: ErrorView(
              message: 'We couldn\'t load this announcement right now.',
              debugDetails: e,
            ),
          );
        },
        data: (a) {
          if (a == null) {
            return const Center(
              child: ErrorView(
                message:
                    'This announcement is no longer available. It may have been removed.',
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(48, 32, 48, 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 14),
                  Text(a.title, style: TereTheme.display(size: 48)),
                  const SizedBox(height: 10),
                  Container(height: 3, width: 96, color: TereTheme.accent),
                  const SizedBox(height: 14),
                  Text(
                    'BY ${a.authorName.toUpperCase()} · ${DateFormat.yMMMd().add_jm().format(a.createdAt).toUpperCase()}',
                    style: TereTheme.overline(
                        size: 11, color: TereTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  Text(a.body, style: TereTheme.body(size: 18).copyWith(height: 1.7)),
                  const SizedBox(height: 24),
                  ReactionBar(announcement: a),
                  const SizedBox(height: 32),
                  const Divider(thickness: 2, color: TereTheme.ink, height: 2),
                  const SizedBox(height: 18),
                  Text('LETTERS · COMMENTS',
                      style: TereTheme.overline(
                          size: 11, color: TereTheme.accent)),
                  const SizedBox(height: 14),
                  CommentThread(announcementId: a.id),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
