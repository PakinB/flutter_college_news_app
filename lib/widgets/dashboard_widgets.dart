import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../models/app_user.dart';
import '../models/faculty.dart';

class StatCardData {
  const StatCardData(this.label, this.value, this.caption, this.valueColor);

  final String label;
  final String value;
  final String caption;
  final Color valueColor;
}

class PageStateView extends StatelessWidget {
  const PageStateView({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.child,
  });

  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFC74A47)),
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('โหลดใหม่'),
              ),
            ],
          ),
        ),
      );
    }
    return child;
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDBD0BF)),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.inbox_outlined, color: Color(0xFF777267)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class DashboardDialog extends StatelessWidget {
  const DashboardDialog({
    super.key,
    required this.title,
    required this.body,
    required this.footer,
    this.maxWidth = 680,
  });

  final String title;
  final Widget body;
  final Widget footer;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                    child: body,
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: footer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.canEdit,
    required this.canApprove,
    required this.onEdit,
    required this.onApprove,
    required this.onDelete,
    required this.onView,
  });

  final Announcement announcement;
  final bool canEdit;
  final bool canApprove;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onDelete;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDBD0BF)),
          ),
          child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: announcement.accent ?? Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _TagPill(label: announcement.priorityLabel, color: announcement.isUrgent ? const Color(0xFFF6C5C3) : const Color(0xFFE3DED4)),
                        _TagPill(label: announcement.statusLabel, color: announcement.isPending ? const Color(0xFFF7D4A7) : const Color(0xFFCDE8B3)),
                        _TagPill(label: announcement.targetLabel, color: const Color(0xFFBBD5F2)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      announcement.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      announcement.content,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF433F36)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      children: <Widget>[
                        Text(announcement.author, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('แก้ไขล่าสุด: ${announcement.updatedAt}'),
                        Text('หมดอายุ: ${announcement.expiredAt}'),
                        const Text('กดเพื่อดูรายละเอียด', style: TextStyle(color: Color(0xFF4E49B7), fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (canEdit || canApprove) ...<Widget>[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          if (canEdit)
                            OutlinedButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('แก้ไข'),
                            ),
                          if (canApprove && announcement.isPending)
                            OutlinedButton.icon(
                              onPressed: onApprove,
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('อนุมัติ'),
                            ),
                          if (canEdit)
                            OutlinedButton.icon(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              label: const Text('ลบ'),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}

Future<void> showAnnouncementDetails({
  required BuildContext context,
  required Announcement announcement,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black45,
    builder: (BuildContext context) {
      return DashboardDialog(
        title: 'รายละเอียดข่าว',
        maxWidth: 760,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _TagPill(label: announcement.priorityLabel, color: announcement.isUrgent ? const Color(0xFFF6C5C3) : const Color(0xFFE3DED4)),
                _TagPill(label: announcement.statusLabel, color: announcement.isPending ? const Color(0xFFF7D4A7) : const Color(0xFFCDE8B3)),
                _TagPill(label: announcement.targetLabel, color: const Color(0xFFBBD5F2)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              announcement.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.35),
            ),
            if (announcement.summary.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                announcement.summary,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF555147)),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              announcement.content,
              style: const TextStyle(fontSize: 16, height: 1.65, color: Color(0xFF2D2A24)),
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _DetailLine(label: 'ผู้ประกาศ', value: announcement.author),
            _DetailLine(label: 'เผยแพร่/สร้างเมื่อ', value: announcement.createdAt),
            _DetailLine(label: 'แก้ไขล่าสุด', value: announcement.updatedAt),
            _DetailLine(label: 'หมดอายุ', value: announcement.expiredAt),
            _DetailLine(label: 'กลุ่มเป้าหมาย', value: announcement.targetLabel),
          ],
        ),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    },
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}

Future<Announcement?> showAnnouncementEditor({
  required BuildContext context,
  required AppUser user,
  required List<Faculty> faculties,
  Announcement? existing,
}) async {
  if (!user.canCreateNews) return null;

  final TextEditingController title = TextEditingController(text: existing?.title ?? '');
  final TextEditingController summary = TextEditingController(text: existing?.summary ?? '');
  final TextEditingController content = TextEditingController(text: existing?.content ?? '');
  final TextEditingController expiredAt = TextEditingController(text: existing?.expiredAt == '-' ? '' : existing?.expiredAt ?? '');

  String priority = existing?.priority ?? 'normal';
  String status = existing?.status ?? (user.isAdmin ? 'published' : 'pending');
  int? targetFacultyId = existing?.targetFacultyId;
  String targetType = existing?.targetType ?? 'all';
  String targetValue = targetType == 'all' || targetFacultyId == null
      ? 'all'
      : 'faculty:$targetFacultyId';
  final Set<String> targetOptions = <String>{
    'all',
    ...faculties.map((Faculty item) => 'faculty:${item.id}'),
  };
  if (!targetOptions.contains(targetValue)) {
    targetValue = 'all';
    targetType = 'all';
    targetFacultyId = null;
  }

  if (user.isTeacher) {
    targetType = 'faculty';
    targetFacultyId = user.facultyId;
    targetValue = 'faculty:${user.facultyId}';
    status = existing?.status ?? 'pending';
  }

  final Announcement? result = await showDialog<Announcement>(
    context: context,
    barrierColor: Colors.black45,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setDialogState) {
          return DashboardDialog(
            title: existing == null ? 'สร้างข่าวใหม่' : 'แก้ไขข่าว',
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DialogText(controller: title, label: 'หัวข้อข่าว *'),
                const SizedBox(height: 14),
                _DialogText(controller: summary, label: 'สรุปข่าว'),
                const SizedBox(height: 14),
                _DialogText(controller: content, label: 'เนื้อหา *', minLines: 5, maxLines: 7),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: priority,
                        decoration: const InputDecoration(labelText: 'ความสำคัญ'),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem(value: 'normal', child: Text('ปกติ')),
                          DropdownMenuItem(value: 'urgent', child: Text('ด่วน')),
                        ],
                        onChanged: (String? value) => setDialogState(() => priority = value ?? priority),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: const InputDecoration(labelText: 'สถานะ'),
                        items: <DropdownMenuItem<String>>[
                          if (user.isAdmin) const DropdownMenuItem(value: 'published', child: Text('เผยแพร่แล้ว')),
                          const DropdownMenuItem(value: 'pending', child: Text('รออนุมัติ')),
                          const DropdownMenuItem(value: 'draft', child: Text('ฉบับร่าง')),
                        ],
                        onChanged: (String? value) => setDialogState(() => status = value ?? status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (user.isPr || user.isAdmin)
                  DropdownButtonFormField<String>(
                    initialValue: targetValue,
                    decoration: const InputDecoration(labelText: 'กระจายข่าวไปยังคณะ'),
                    items: <DropdownMenuItem<String>>[
                      const DropdownMenuItem<String>(value: 'all', child: Text('ทุกคณะ')),
                      ...faculties.map(
                        (Faculty item) => DropdownMenuItem<String>(
                          value: 'faculty:${item.id}',
                          child: Text(item.name),
                        ),
                      ),
                    ],
                    onChanged: (String? value) {
                      setDialogState(() {
                        targetValue = value ?? 'all';
                        targetType = targetValue == 'all' ? 'all' : 'faculty';
                        targetFacultyId = targetType == 'all'
                            ? null
                            : int.tryParse(targetValue.replaceFirst('faculty:', ''));
                      });
                    },
                  )
                else
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'คณะ'),
                    child: Text(
                      faculties.where((Faculty item) => item.id == user.facultyId).firstOrNull?.name ?? 'คณะของผู้ใช้',
                    ),
                  ),
                const SizedBox(height: 14),
                _DialogText(controller: expiredAt, label: 'วันหมดอายุ (YYYY-MM-DD)'),
              ],
            ),
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('ยกเลิก')),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () {
                    if (title.text.trim().isEmpty || content.text.trim().isEmpty) return;
                    Navigator.of(context).pop(
                      Announcement(
                        id: existing?.id ?? 0,
                        title: title.text.trim(),
                        summary: summary.text.trim(),
                        content: content.text.trim(),
                        author: existing?.author ?? user.name,
                        status: status,
                        priority: priority,
                        targetType: targetType,
                        targetFacultyId: targetFacultyId,
                        targetFacultyName: faculties.where((Faculty item) => item.id == targetFacultyId).firstOrNull?.name ?? 'ทุกคณะ',
                        createdAt: existing?.createdAt ?? '-',
                        updatedAt: DateTime.now().toIso8601String(),
                        expiredAt: expiredAt.text.trim().isEmpty ? '-' : expiredAt.text.trim(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: Text(existing == null ? 'สร้างข่าว' : 'บันทึก'),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  title.dispose();
  summary.dispose();
  content.dispose();
  expiredAt.dispose();
  return result;
}

class _DialogText extends StatelessWidget {
  const _DialogText({
    required this.controller,
    required this.label,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}
