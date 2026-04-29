import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../models/app_user.dart';
import '../widgets/dashboard_widgets.dart';

class AllNewsPage extends StatelessWidget {
  const AllNewsPage({
    super.key,
    required this.title,
    required this.announcements,
    required this.currentUser,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onEdit,
    required this.onApprove,
    required this.onDelete,
  });

  final String title;
  final List<Announcement> announcements;
  final AppUser currentUser;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final ValueChanged<Announcement> onEdit;
  final ValueChanged<Announcement> onApprove;
  final ValueChanged<Announcement> onDelete;

  @override
  Widget build(BuildContext context) {
    return PageStateView(
      isLoading: isLoading,
      error: error,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            NewsListBody(
              announcements: announcements,
              currentUser: currentUser,
              emptyMessage: 'ยังไม่มีข้อมูลในหน้านี้',
              onEdit: onEdit,
              onApprove: onApprove,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class NewsListBody extends StatelessWidget {
  const NewsListBody({
    super.key,
    required this.announcements,
    required this.currentUser,
    required this.emptyMessage,
    required this.onEdit,
    required this.onApprove,
    required this.onDelete,
  });

  final List<Announcement> announcements;
  final AppUser currentUser;
  final String emptyMessage;
  final ValueChanged<Announcement> onEdit;
  final ValueChanged<Announcement> onApprove;
  final ValueChanged<Announcement> onDelete;

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) return EmptyState(message: emptyMessage);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: announcements.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final Announcement item = announcements[index];
        final bool ownsFaculty = currentUser.facultyId != null && item.targetFacultyId == currentUser.facultyId;
        final bool canEdit = currentUser.isAdmin || currentUser.isPr || (currentUser.isTeacher && ownsFaculty);
        return AnnouncementCard(
          announcement: item,
          canEdit: canEdit,
          canApprove: currentUser.isAdmin,
          onEdit: () => onEdit(item),
          onApprove: () => onApprove(item),
          onDelete: () => onDelete(item),
        );
      },
    );
  }
}
