import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../models/app_user.dart';
import 'all_news_page.dart';

class PendingNewsPage extends StatelessWidget {
  const PendingNewsPage({
    super.key,
    required this.announcements,
    required this.currentUser,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onEdit,
    required this.onApprove,
    required this.onDelete,
  });

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
    return AllNewsPage(
      title: 'รออนุมัติ',
      announcements: announcements.where((Announcement item) => item.isPending).toList(),
      currentUser: currentUser,
      isLoading: isLoading,
      error: error,
      onRefresh: onRefresh,
      onEdit: onEdit,
      onApprove: onApprove,
      onDelete: onDelete,
    );
  }
}
