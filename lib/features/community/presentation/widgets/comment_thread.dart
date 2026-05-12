import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/comments_repository.dart';
import '../providers/community_providers.dart';

class CommentThread extends ConsumerStatefulWidget {
  const CommentThread({super.key, required this.announcementId});
  final String announcementId;

  @override
  ConsumerState<CommentThread> createState() => _CommentThreadState();
}

class _CommentThreadState extends ConsumerState<CommentThread> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(commentsRepositoryProvider).add(
            announcementId: widget.announcementId,
            authorId: user.uid,
            authorName: user.displayName,
            body: text,
          );
      _controller.clear();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync =
        ref.watch(commentsForAnnouncementProvider(widget.announcementId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Add to the conversation...'),
                onSubmitted: (_) => _post(),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: _busy ? null : _post,
                child: _busy
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: TereTheme.paper))
                    : const Text('POST'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        commentsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, st) {
            logError('Failed to load comments for ${widget.announcementId}',
                e, st);
            return Text(
              'Comments couldn\'t be loaded right now.',
              style: TereTheme.body(size: 14, color: TereTheme.accent),
            );
          },
          data: (comments) {
            if (comments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'NO COMMENTS YET',
                  style: TereTheme.overline(
                      size: 11, color: TereTheme.textSecondary),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in comments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                              color: TereTheme.borderMedium, width: 3),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 8, 0, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                color: TereTheme.ink,
                                alignment: Alignment.center,
                                child: Text(
                                  c.authorName.characters.first.toUpperCase(),
                                  style: TereTheme.overline(
                                      size: 11, color: TereTheme.paper),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(c.authorName,
                                  style: TereTheme.body(
                                      size: 13, weight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat.MMMd()
                                    .add_jm()
                                    .format(c.createdAt)
                                    .toUpperCase(),
                                style: TereTheme.overline(
                                    size: 10,
                                    color: TereTheme.textTertiary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(c.body, style: TereTheme.body(size: 14)),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
