import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../models/app_user.dart';
import '../models/faculty.dart';
import '../widgets/dashboard_widgets.dart';
import 'all_news_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({
    super.key,
    required this.currentUser,
    required this.announcements,
    required this.faculties,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onCreateNews,
    required this.onEditNews,
    required this.onApproveNews,
    required this.onDeleteNews,
  });

  final AppUser currentUser;
  final List<Announcement> announcements;
  final List<Faculty> faculties;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final VoidCallback onCreateNews;
  final ValueChanged<Announcement> onEditNews;
  final ValueChanged<Announcement> onApproveNews;
  final ValueChanged<Announcement> onDeleteNews;

  @override
  Widget build(BuildContext context) {
    final int published = announcements.where((Announcement item) => item.isPublished).length;
    final int pending = announcements.where((Announcement item) => item.isPending).length;
    final int urgent = announcements.where((Announcement item) => item.isUrgent).length;
    final List<StatCardData> stats = <StatCardData>[
      StatCardData('ข่าวทั้งหมด', '${announcements.length}', 'จากฐานข้อมูล', const Color(0xFF232323)),
      StatCardData('เผยแพร่แล้ว', '$published', 'กำลังแสดง', const Color(0xFF5E9734)),
      StatCardData('รออนุมัติ', '$pending', 'ต้องดำเนินการ', const Color(0xFFAF7320)),
      StatCardData('ข่าวด่วน', '$urgent', 'ความสำคัญสูง', const Color(0xFFC74A47)),
    ];

    return PageStateView(
      isLoading: isLoading,
      error: error,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    currentUser.isAdmin ? 'Dashboard สำหรับแอดมิน' : 'Dashboard',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
                if (currentUser.canCreateNews)
                  FilledButton.icon(
                    onPressed: onCreateNews,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('สร้างข่าวใหม่'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _StatsGrid(stats: stats),
            const SizedBox(height: 18),
            const Text('ข่าวล่าสุด', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            NewsListBody(
              announcements: announcements.take(6).toList(),
              currentUser: currentUser,
              emptyMessage: 'ยังไม่มีข่าวประกาศในฐานข้อมูล',
              onEdit: onEditNews,
              onApprove: onApproveNews,
              onDelete: onDeleteNews,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<StatCardData> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 760;
        final double width = wide ? (constraints.maxWidth - 36) / 4 : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: stats.map((StatCardData item) {
            return SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.label, style: const TextStyle(color: Color(0xFF615C52))),
                    const SizedBox(height: 16),
                    Text(item.value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: item.valueColor)),
                    const SizedBox(height: 4),
                    Text(item.caption, style: const TextStyle(color: Color(0xFF7A7568))),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
