import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/announcements_repository.dart';
import '../../data/comments_repository.dart';
import '../../domain/announcement.dart';
import '../../domain/comment.dart';

final announcementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  return ref.watch(announcementsRepositoryProvider).watchAll();
});

final announcementByIdProvider =
    StreamProvider.family<Announcement?, String>((ref, id) {
  return ref.watch(announcementsRepositoryProvider).watchById(id);
});

final commentsForAnnouncementProvider =
    StreamProvider.family<List<Comment>, String>((ref, id) {
  return ref.watch(commentsRepositoryProvider).watch(id);
});
