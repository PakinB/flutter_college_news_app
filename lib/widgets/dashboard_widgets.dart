import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFC74A47),
              ),
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
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: constraints.maxHeight,
              ),
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
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
                    Padding(padding: const EdgeInsets.all(16), child: footer),
                  ],
                ),
              ),
            ),
          );
        },
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            _TagPill(
                              label: announcement.priorityLabel,
                              color: announcement.isUrgent
                                  ? const Color(0xFFF6C5C3)
                                  : const Color(0xFFE3DED4),
                            ),
                            _TagPill(
                              label: announcement.statusLabel,
                              color: announcement.isPending
                                  ? const Color(0xFFF7D4A7)
                                  : const Color(0xFFCDE8B3),
                            ),
                            _TagPill(
                              label: announcement.targetLabel,
                              color: const Color(0xFFBBD5F2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          announcement.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                        if (announcement.imageUrls.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 12),
                          _AnnouncementImage(
                            imageUrl: announcement.imageUrls.first,
                            maxHeight: 260,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          announcement.content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF433F36),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 14,
                          runSpacing: 8,
                          children: <Widget>[
                            Text(
                              announcement.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text('แก้ไขล่าสุด: ${announcement.updatedAt}'),
                            Text('หมดอายุ: ${announcement.expiredAt}'),
                            const Text(
                              'กดเพื่อดูรายละเอียด',
                              style: TextStyle(
                                color: Color(0xFF4E49B7),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('แก้ไข'),
                                ),
                              if (canApprove && announcement.isPending)
                                OutlinedButton.icon(
                                  onPressed: onApprove,
                                  icon: const Icon(
                                    Icons.check_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('อนุมัติ'),
                                ),
                              if (canEdit)
                                OutlinedButton.icon(
                                  onPressed: onDelete,
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                  ),
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
                _TagPill(
                  label: announcement.priorityLabel,
                  color: announcement.isUrgent
                      ? const Color(0xFFF6C5C3)
                      : const Color(0xFFE3DED4),
                ),
                _TagPill(
                  label: announcement.statusLabel,
                  color: announcement.isPending
                      ? const Color(0xFFF7D4A7)
                      : const Color(0xFFCDE8B3),
                ),
                _TagPill(
                  label: announcement.targetLabel,
                  color: const Color(0xFFBBD5F2),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
            if (announcement.summary.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                announcement.summary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF555147),
                ),
              ),
            ],
            if (announcement.imageUrls.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              _AnnouncementImageCarousel(
                imageUrls: announcement.imageUrls,
                maxHeight: 460,
              ),
            ],
            const SizedBox(height: 14),
            Text(
              announcement.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.65,
                color: Color(0xFF2D2A24),
              ),
            ),
            if (announcement.linkAttachments.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              _AttachmentActionSection(
                title: 'link',
                files: announcement.linkAttachments,
                icon: Icons.link_rounded,
              ),
            ],
            if (announcement.downloadFileAttachments.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              _AttachmentActionSection(
                title: 'download file',
                files: announcement.downloadFileAttachments,
                icon: Icons.download_outlined,
              ),
            ],
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _DetailLine(label: 'ผู้ประกาศ', value: announcement.author),
            _DetailLine(
              label: 'เผยแพร่/สร้างเมื่อ',
              value: announcement.createdAt,
            ),
            _DetailLine(label: 'แก้ไขล่าสุด', value: announcement.updatedAt),
            _DetailLine(label: 'หมดอายุ', value: announcement.expiredAt),
            _DetailLine(
              label: 'กลุ่มเป้าหมาย',
              value: announcement.targetLabel,
            ),
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

Future<void> showLatestAnnouncementPopup({
  required BuildContext context,
  required Announcement announcement,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black45,
    builder: (BuildContext context) {
      return DashboardDialog(
        title: 'ข่าวใหม่ล่าสุด',
        maxWidth: 720,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                const _TagPill(
                  label: 'หัวข้อข่าวใหม่',
                  color: Color(0xFFD9D1FF),
                ),
                _TagPill(
                  label: announcement.isEmployeeTarget
                      ? 'ข่าวพนักงาน'
                      : announcement.isAllFaculty
                      ? 'ข่าวทุกคน'
                      : 'ข่าวคณะ',
                  color: announcement.isAllFaculty
                      ? const Color(0xFFCDE8B3)
                      : announcement.isEmployeeTarget
                      ? const Color(0xFFFFDCA8)
                      : const Color(0xFFBBD5F2),
                ),
                if (!announcement.isAllFaculty &&
                    !announcement.isEmployeeTarget)
                  _TagPill(
                    label: announcement.targetFacultyName,
                    color: const Color(0xFFE3DED4),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'หัวข้อข่าว',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B665C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
            if (announcement.imageUrls.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              _AnnouncementImageCarousel(
                imageUrls: announcement.imageUrls,
                maxHeight: 420,
              ),
            ],
            const SizedBox(height: 16),
            _DetailLine(
              label: 'คณะ',
              value: announcement.isAllFaculty
                  ? 'ข่าวทุกคน'
                  : announcement.isEmployeeTarget
                  ? 'ข่าวพนักงาน'
                  : announcement.targetFacultyName,
            ),
            _DetailLine(label: 'ผู้ประกาศ', value: announcement.author),
            _DetailLine(label: 'วันที่ข่าว', value: announcement.createdAt),
            if (announcement.summary.isNotEmpty)
              _DetailLine(label: 'สรุปข่าว', value: announcement.summary),
            const SizedBox(height: 8),
            Text(
              announcement.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.65,
                color: Color(0xFF2D2A24),
              ),
            ),
            if (announcement.linkAttachments.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              _AttachmentActionSection(
                title: 'link',
                files: announcement.linkAttachments,
                icon: Icons.link_rounded,
              ),
            ],
            if (announcement.downloadFileAttachments.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              _AttachmentActionSection(
                title: 'download file',
                files: announcement.downloadFileAttachments,
                icon: Icons.download_outlined,
              ),
            ],
          ],
        ),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด'),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('รับทราบ'),
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
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _AttachmentActionSection extends StatelessWidget {
  const _AttachmentActionSection({
    required this.title,
    required this.files,
    required this.icon,
  });

  final String title;
  final List<AnnouncementAttachment> files;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        for (final AnnouncementAttachment file in files)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              onPressed: () => _openDownloadUrl(context, file.fileUrl),
              icon: Icon(icon),
              label: Text(
                file.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openDownloadUrl(BuildContext context, String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลิงก์ไฟล์ไม่ถูกต้อง')),
      );
      return;
    }

    final bool opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเปิดลิงก์ดาวน์โหลดได้')),
      );
    }
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AnnouncementImage extends StatelessWidget {
  const _AnnouncementImage({required this.imageUrl, required this.maxHeight});

  final String imageUrl;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stack) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  color: const Color(0xFFF1ECE3),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.broken_image_outlined,
                        color: Color(0xFF777267),
                      ),
                      SizedBox(width: 8),
                      Text('ไม่สามารถโหลดรูปภาพได้'),
                    ],
                  ),
                );
              },
        ),
      ),
    );
  }
}

class _AnnouncementImageGallery extends StatelessWidget {
  const _AnnouncementImageGallery({
    required this.imageUrls,
    required this.maxHeight,
  });

  final List<String> imageUrls;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.length == 1) {
      return _AnnouncementImage(
        imageUrl: imageUrls.first,
        maxHeight: maxHeight,
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columnCount = constraints.maxWidth >= 520 ? 2 : 1;
        return GridView.builder(
          itemCount: imageUrls.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 16 / 9,
          ),
          itemBuilder: (BuildContext context, int index) {
            return _AnnouncementImage(
              imageUrl: imageUrls[index],
              maxHeight: maxHeight,
            );
          },
        );
      },
    );
  }
}

class _AnnouncementImageCarousel extends StatefulWidget {
  const _AnnouncementImageCarousel({
    required this.imageUrls,
    required this.maxHeight,
  });

  final List<String> imageUrls;
  final double maxHeight;

  @override
  State<_AnnouncementImageCarousel> createState() =>
      _AnnouncementImageCarouselState();
}

class _AnnouncementImageCarouselState
    extends State<_AnnouncementImageCarousel> {
  late final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showImage(int index) {
    final int targetIndex = index
        .clamp(0, widget.imageUrls.length - 1)
        .toInt();
    _controller.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.length == 1) {
      return _AnnouncementImage(
        imageUrl: widget.imageUrls.first,
        maxHeight: widget.maxHeight,
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double viewportHeight = (constraints.maxWidth * 9 / 16)
            .clamp(180.0, widget.maxHeight)
            .toDouble();

        return Column(
          children: <Widget>[
            SizedBox(
              height: viewportHeight,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: widget.imageUrls.length,
                      onPageChanged: (int index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return _CarouselImage(
                          imageUrl: widget.imageUrls[index],
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 8,
                    child: _ImageNavButton(
                      icon: Icons.chevron_left_rounded,
                      tooltip: 'รูปก่อนหน้า',
                      onPressed: _currentIndex == 0
                          ? null
                          : () => _showImage(_currentIndex - 1),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    child: _ImageNavButton(
                      icon: Icons.chevron_right_rounded,
                      tooltip: 'รูปถัดไป',
                      onPressed: _currentIndex == widget.imageUrls.length - 1
                          ? null
                          : () => _showImage(_currentIndex + 1),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${widget.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CarouselImage extends StatelessWidget {
  const _CarouselImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(18),
          color: const Color(0xFFF1ECE3),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.broken_image_outlined, color: Color(0xFF777267)),
              SizedBox(width: 8),
              Text('ไม่สามารถโหลดรูปภาพได้'),
            ],
          ),
        );
      },
    );
  }
}

class _ImageNavButton extends StatelessWidget {
  const _ImageNavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(onPressed == null ? 0.45 : 0.88),
      shape: const CircleBorder(),
      elevation: onPressed == null ? 0 : 2,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
        color: const Color(0xFF2D2A24),
      ),
    );
  }
}

// ignore: unused_element
class _SelectedImagePreview extends StatelessWidget {
  const _SelectedImagePreview({
    required this.imageFiles,
    required this.currentImageUrls,
    required this.onPick,
    required this.onClear,
  });

  final List<XFile> imageFiles;
  final List<String> currentImageUrls;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageFiles.isNotEmpty || currentImageUrls.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'รูปภาพข่าว',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (hasImage)
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('ล้างรูป'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (imageFiles.isNotEmpty)
          _SelectedImageFileGrid(imageFiles: imageFiles)
        else if (currentImageUrls.isNotEmpty)
          _AnnouncementImageGallery(imageUrls: currentImageUrls, maxHeight: 260)
        else
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('เลือกรูปภาพ'),
          ),
        if (hasImage) ...<Widget>[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.image_search_outlined),
            label: const Text('เปลี่ยนรูปภาพ'),
          ),
        ],
      ],
    );
  }
}

class _SelectedImagePreviewV2 extends StatelessWidget {
  const _SelectedImagePreviewV2({
    required this.imageFiles,
    required this.currentImageUrls,
    required this.onPick,
    required this.onClear,
  });

  final List<XFile> imageFiles;
  final List<String> currentImageUrls;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageFiles.isNotEmpty || currentImageUrls.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'รูปภาพข่าว',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (hasImage)
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('ล้างรูป'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasImage) ...<Widget>[
          if (currentImageUrls.isNotEmpty)
            _AnnouncementImageGallery(
              imageUrls: currentImageUrls,
              maxHeight: 260,
            ),
          if (currentImageUrls.isNotEmpty && imageFiles.isNotEmpty)
            const SizedBox(height: 10),
          if (imageFiles.isNotEmpty)
            _SelectedImageFileGrid(imageFiles: imageFiles),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('เพิ่มรูปภาพ'),
          ),
        ] else
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('เลือกรูปภาพ'),
          ),
      ],
    );
  }
}

class _SelectedImageFileGrid extends StatelessWidget {
  const _SelectedImageFileGrid({required this.imageFiles});

  final List<XFile> imageFiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columnCount = constraints.maxWidth >= 520 ? 2 : 1;
        return GridView.builder(
          itemCount: imageFiles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 16 / 9,
          ),
          itemBuilder: (BuildContext context, int index) {
            return FutureBuilder<Uint8List>(
              future: imageFiles[index].readAsBytes(),
              builder:
                  (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        snapshot.data!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
            );
          },
        );
      },
    );
  }
}

// ignore: unused_element
class _SelectedAttachmentPreview extends StatelessWidget {
  const _SelectedAttachmentPreview({
    required this.selectedFiles,
    required this.currentFiles,
    required this.onPick,
    required this.onClear,
  });

  final List<PickedAnnouncementAttachment> selectedFiles;
  final List<AnnouncementAttachment> currentFiles;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool hasFiles = selectedFiles.isNotEmpty || currentFiles.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'ไฟล์แนบ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (hasFiles)
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('ล้างไฟล์'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasFiles)
          Column(
            children: <Widget>[
              for (final PickedAnnouncementAttachment file in selectedFiles)
                _AttachmentRow(
                  icon: Icons.insert_drive_file_outlined,
                  title: file.fileName,
                  subtitle: 'รออัปโหลด',
                ),
              for (final AnnouncementAttachment file in currentFiles)
                _AttachmentRow(
                  icon: Icons.attach_file_rounded,
                  title: file.fileName,
                  subtitle: file.fileUrl,
                ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('เลือกไฟล์แนบ'),
          ),
        if (hasFiles) ...<Widget>[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('เพิ่ม/เปลี่ยนไฟล์แนบ'),
          ),
        ],
      ],
    );
  }
}

// ignore: unused_element
class _SelectedLinkAttachmentPreview extends StatelessWidget {
  const _SelectedLinkAttachmentPreview({
    required this.selectedLinks,
    required this.currentLinks,
    required this.controller,
    required this.onAdd,
    required this.onClear,
  });

  final List<PickedAnnouncementAttachment> selectedLinks;
  final List<AnnouncementAttachment> currentLinks;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool hasLinks = selectedLinks.isNotEmpty || currentLinks.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'download file',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (hasLinks)
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('ล้างลิงก์'),
              ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'รองรับเฉพาะ URL หรือลิงก์ไฟล์เท่านั้น ไม่สามารถอัปโหลดไฟล์รูปภาพในหัวข้อนี้ได้',
          style: TextStyle(color: Color(0xFFC74A47), fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL หรือ ลิงก์ไฟล์',
                  hintText: 'https://example.com/file.pdf',
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_link_rounded),
              label: const Text('เพิ่ม'),
            ),
          ],
        ),
        if (hasLinks) ...<Widget>[
          const SizedBox(height: 10),
          for (final AnnouncementAttachment link in currentLinks)
            _AttachmentRow(
              icon: Icons.link_rounded,
              title: link.fileName,
              subtitle: link.fileUrl,
            ),
          for (final PickedAnnouncementAttachment link in selectedLinks)
            _AttachmentRow(
              icon: Icons.add_link_rounded,
              title: link.fileName,
              subtitle: 'รอบันทึก',
            ),
        ],
      ],
    );
  }
}

// ignore: unused_element
class _SelectedDownloadAttachmentPreview extends StatelessWidget {
  const _SelectedDownloadAttachmentPreview({
    required this.selectedLinks,
    required this.currentLinks,
    required this.controller,
    required this.onAdd,
    required this.onPickFiles,
    required this.onClear,
  });

  final List<PickedAnnouncementAttachment> selectedLinks;
  final List<AnnouncementAttachment> currentLinks;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final VoidCallback onPickFiles;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool hasLinks = selectedLinks.isNotEmpty || currentLinks.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'download file',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (hasLinks)
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('ล้างไฟล์'),
              ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'รองรับ URL หรือลิงก์ไฟล์ และไฟล์เอกสารจากเครื่อง ไม่สามารถอัปโหลดไฟล์รูปภาพในหัวข้อนี้ได้',
          style: TextStyle(color: Color(0xFFC74A47), fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL หรือ ลิงก์ไฟล์',
                  hintText: 'https://example.com/file.pdf',
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_link_rounded),
              label: const Text('เพิ่ม'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onPickFiles,
          icon: const Icon(Icons.attach_file_rounded),
          label: const Text('เลือกไฟล์จากเครื่อง'),
        ),
        if (hasLinks) ...<Widget>[
          const SizedBox(height: 10),
          for (final AnnouncementAttachment link in currentLinks)
            _AttachmentRow(
              icon: Icons.link_rounded,
              title: link.fileName,
              subtitle: link.fileUrl,
            ),
          for (final PickedAnnouncementAttachment link in selectedLinks)
            _AttachmentRow(
              icon: link.isUrl
                  ? Icons.add_link_rounded
                  : Icons.insert_drive_file_outlined,
              title: link.fileName,
              subtitle: link.isUrl ? 'รอบันทึกลิงก์' : 'รออัปโหลด',
            ),
        ],
      ],
    );
  }
}

class _SeparatedAttachmentEditor extends StatelessWidget {
  const _SeparatedAttachmentEditor({
    required this.selectedAttachments,
    required this.currentAttachments,
    required this.controller,
    required this.onAddLink,
    required this.onPickFiles,
    required this.onClear,
  });

  final List<PickedAnnouncementAttachment> selectedAttachments;
  final List<AnnouncementAttachment> currentAttachments;
  final TextEditingController controller;
  final VoidCallback onAddLink;
  final VoidCallback onPickFiles;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final List<AnnouncementAttachment> currentLinks = currentAttachments
        .where((AnnouncementAttachment item) => item.isLink)
        .toList();
    final List<AnnouncementAttachment> currentFiles = currentAttachments
        .where((AnnouncementAttachment item) => !item.isLink)
        .toList();
    final List<PickedAnnouncementAttachment> selectedLinks =
        selectedAttachments
            .where((PickedAnnouncementAttachment item) => item.isUrl)
            .toList();
    final List<PickedAnnouncementAttachment> selectedFiles =
        selectedAttachments
            .where((PickedAnnouncementAttachment item) => !item.isUrl)
            .toList();
    final bool hasAttachments =
        selectedAttachments.isNotEmpty || currentAttachments.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'link',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (hasAttachments)
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('ล้างทั้งหมด'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL หรือ ลิงก์',
                  hintText: 'https://example.com',
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: onAddLink,
              icon: const Icon(Icons.add_link_rounded),
              label: const Text('เพิ่ม'),
            ),
          ],
        ),
        if (currentLinks.isNotEmpty || selectedLinks.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          for (final AnnouncementAttachment link in currentLinks)
            _AttachmentRow(
              icon: Icons.link_rounded,
              title: link.fileName,
              subtitle: link.fileUrl,
            ),
          for (final PickedAnnouncementAttachment link in selectedLinks)
            _AttachmentRow(
              icon: Icons.add_link_rounded,
              title: link.fileName,
              subtitle: 'รอบันทึกลิงก์',
            ),
        ],
        const SizedBox(height: 14),
        Text(
          'download file',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'เลือกไฟล์เอกสารจากเครื่อง ไม่สามารถอัปโหลดไฟล์รูปภาพในหัวข้อนี้ได้',
          style: TextStyle(color: Color(0xFFC74A47), fontSize: 12),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onPickFiles,
          icon: const Icon(Icons.attach_file_rounded),
          label: const Text('เลือกไฟล์จากเครื่อง'),
        ),
        if (currentFiles.isNotEmpty || selectedFiles.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          for (final AnnouncementAttachment file in currentFiles)
            _AttachmentRow(
              icon: Icons.download_outlined,
              title: file.fileName,
              subtitle: file.fileUrl,
            ),
          for (final PickedAnnouncementAttachment file in selectedFiles)
            _AttachmentRow(
              icon: Icons.insert_drive_file_outlined,
              title: file.fileName,
              subtitle: 'รออัปโหลด',
            ),
        ],
      ],
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: const Color(0xFF555147)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777267),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnnouncementEditorResult {
  const AnnouncementEditorResult({
    required this.announcement,
    required this.imageAttachments,
    required this.fileAttachments,
    required this.clearExistingImages,
    required this.clearExistingFiles,
  });

  final Announcement announcement;
  final List<PickedAnnouncementAttachment> imageAttachments;
  final List<PickedAnnouncementAttachment> fileAttachments;
  final bool clearExistingImages;
  final bool clearExistingFiles;
}

class PickedAnnouncementAttachment {
  const PickedAnnouncementAttachment({
    required this.fileName,
    required this.readAsBytes,
    this.isUrl = false,
  });

  final String fileName;
  final Future<Uint8List> Function() readAsBytes;
  final bool isUrl;

  factory PickedAnnouncementAttachment.fromXFile(XFile file) {
    return PickedAnnouncementAttachment(
      fileName: file.name,
      readAsBytes: file.readAsBytes,
    );
  }

  factory PickedAnnouncementAttachment.fromPlatformFile(PlatformFile file) {
    final Uint8List bytes = file.bytes ?? Uint8List(0);
    return PickedAnnouncementAttachment(
      fileName: file.name,
      readAsBytes: () async => bytes,
    );
  }

  factory PickedAnnouncementAttachment.fromUrl(String url) {
    return PickedAnnouncementAttachment(
      fileName: url,
      readAsBytes: () async => Uint8List(0),
      isUrl: true,
    );
  }
}

Future<AnnouncementEditorResult?> showAnnouncementEditor({
  required BuildContext context,
  required AppUser user,
  required List<Faculty> faculties,
  Announcement? existing,
}) async {
  if (!user.canCreateNews) return null;

  final TextEditingController title = TextEditingController(
    text: existing?.title ?? '',
  );
  final TextEditingController summary = TextEditingController(
    text: existing?.summary ?? '',
  );
  final TextEditingController content = TextEditingController(
    text: existing?.content ?? '',
  );
  final TextEditingController expiredAt = TextEditingController(
    text: existing?.expiredAt == '-' ? '' : existing?.expiredAt ?? '',
  );
  final TextEditingController attachmentUrl = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> selectedImages = <XFile>[];
  List<String> currentImageUrls = existing?.imageUrls ?? <String>[];
  List<PickedAnnouncementAttachment> selectedFiles =
      <PickedAnnouncementAttachment>[];
  List<AnnouncementAttachment> currentFiles =
      existing?.fileAttachments ?? <AnnouncementAttachment>[];
  bool clearExistingImages = false;
  bool clearExistingFiles = false;

  final List<Faculty> facultyOptions = _uniqueFacultiesById(faculties);
  String priority = _editorPriority(existing?.priority);
  String status = _editorStatus(
    existing?.status ?? (user.isAdmin ? 'published' : 'pending'),
  );
  final bool canSelectPublishedStatus = user.isAdmin || status == 'published';
  int? targetFacultyId = existing?.targetFacultyId;
  String targetType = existing?.targetType ?? 'all';
  String targetValue = targetType == 'employee'
      ? 'employee'
      : targetType == 'all' || targetFacultyId == null
      ? 'all'
      : 'faculty:$targetFacultyId';
  final Set<String> targetOptions = <String>{
    'all',
    'employee',
    ...facultyOptions.map((Faculty item) => 'faculty:${item.id}'),
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
    status = _editorStatus(existing?.status ?? 'pending');
  }

  final AnnouncementEditorResult?
  result = await showDialog<AnnouncementEditorResult>(
    context: context,
    barrierColor: Colors.black45,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (
              BuildContext context,
              void Function(void Function()) setDialogState,
            ) {
              return DashboardDialog(
                title: existing == null ? 'สร้างข่าวใหม่' : 'แก้ไขข่าว',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _DialogText(controller: title, label: 'หัวข้อข่าว *'),
                    const SizedBox(height: 14),
                    _DialogText(controller: summary, label: 'สรุปข่าว'),
                    const SizedBox(height: 14),
                    _DialogText(
                      controller: content,
                      label: 'เนื้อหา *',
                      minLines: 5,
                      maxLines: 7,
                    ),
                    const SizedBox(height: 14),
                    _SelectedImagePreviewV2(
                      imageFiles: selectedImages,
                      currentImageUrls: currentImageUrls,
                      onPick: () async {
                        final List<XFile> images = await imagePicker
                            .pickMultiImage();
                        if (images.isEmpty) return;
                        setDialogState(() {
                          selectedImages = <XFile>[
                            ...selectedImages,
                            ...images,
                          ];
                        });
                      },
                      onClear: () => setDialogState(() {
                        selectedImages = <XFile>[];
                        currentImageUrls = <String>[];
                        clearExistingImages = true;
                      }),
                    ),
                    const SizedBox(height: 14),
                    _SeparatedAttachmentEditor(
                      selectedAttachments: selectedFiles,
                      currentAttachments: currentFiles,
                      controller: attachmentUrl,
                      onAddLink: () {
                        final String url = attachmentUrl.text.trim();
                        final Uri? uri = Uri.tryParse(url);
                        if (uri == null || !uri.hasScheme) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('กรุณากรอก URL ให้ถูกต้อง'),
                            ),
                          );
                          return;
                        }
                        if (_isImageUrl(url)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'หัวข้อ download file ไม่รองรับไฟล์รูปภาพ กรุณาใช้ช่องรูปภาพข่าวแทน',
                              ),
                            ),
                          );
                          return;
                        }
                        setDialogState(() {
                          selectedFiles = <PickedAnnouncementAttachment>[
                            ...selectedFiles,
                            PickedAnnouncementAttachment.fromUrl(url),
                          ];
                          attachmentUrl.clear();
                        });
                      },
                      onPickFiles: () async {
                        final FilePickerResult? result = await FilePicker
                            .platform
                            .pickFiles(
                              allowMultiple: true,
                              withData: true,
                              type: FileType.custom,
                              allowedExtensions: const <String>[
                                'pdf',
                                'doc',
                                'docx',
                                'xls',
                                'xlsx',
                                'ppt',
                                'pptx',
                                'txt',
                                'csv',
                                'zip',
                              ],
                            );
                        if (result == null || result.files.isEmpty) return;

                        final List<PlatformFile> files = result.files
                            .where((PlatformFile file) {
                              return !_isImageUrl(file.name) &&
                                  file.bytes != null;
                            })
                            .toList();
                        if (files.length != result.files.length) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'ไม่สามารถอัปโหลดไฟล์รูปภาพในหัวข้อ download file ได้',
                              ),
                            ),
                          );
                        }
                        if (files.isEmpty) return;

                        setDialogState(() {
                          selectedFiles = <PickedAnnouncementAttachment>[
                            ...selectedFiles,
                            ...files.map(
                              PickedAnnouncementAttachment.fromPlatformFile,
                            ),
                          ];
                        });
                      },
                      onClear: () => setDialogState(() {
                        selectedFiles = <PickedAnnouncementAttachment>[];
                        currentFiles = <AnnouncementAttachment>[];
                        clearExistingFiles = true;
                      }),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: priority,
                            decoration: const InputDecoration(
                              labelText: 'ความสำคัญ',
                            ),
                            items: const <DropdownMenuItem<String>>[
                              DropdownMenuItem(
                                value: 'normal',
                                child: Text('ปกติ'),
                              ),
                              DropdownMenuItem(
                                value: 'urgent',
                                child: Text('ด่วน'),
                              ),
                            ],
                            onChanged: (String? value) => setDialogState(
                              () => priority = value ?? priority,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: status,
                            decoration: const InputDecoration(
                              labelText: 'สถานะ',
                            ),
                            items: <DropdownMenuItem<String>>[
                              if (canSelectPublishedStatus)
                                const DropdownMenuItem(
                                  value: 'published',
                                  child: Text('เผยแพร่แล้ว'),
                                ),
                              const DropdownMenuItem(
                                value: 'pending',
                                child: Text('รออนุมัติ'),
                              ),
                              const DropdownMenuItem(
                                value: 'draft',
                                child: Text('ฉบับร่าง'),
                              ),
                            ],
                            onChanged: (String? value) =>
                                setDialogState(() => status = value ?? status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (user.isPr || user.isAdmin)
                      DropdownButtonFormField<String>(
                        initialValue: targetValue,
                        decoration: const InputDecoration(
                          labelText: 'หมวดหมู่ข่าว',
                        ),
                        items: <DropdownMenuItem<String>>[
                          const DropdownMenuItem<String>(
                            value: 'all',
                            child: Text('ทุกคน'),
                          ),
                          const DropdownMenuItem<String>(
                            value: 'employee',
                            child: Text('พนักงาน'),
                          ),
                          ...facultyOptions.map(
                            (Faculty item) => DropdownMenuItem<String>(
                              value: 'faculty:${item.id}',
                              child: Text(item.name),
                            ),
                          ),
                        ],
                        onChanged: (String? value) {
                          setDialogState(() {
                            targetValue = value ?? 'all';
                            targetType = targetValue == 'all'
                                ? 'all'
                                : targetValue == 'employee'
                                ? 'employee'
                                : 'faculty';
                            targetFacultyId = targetType == 'faculty'
                                ? int.tryParse(
                                    targetValue.replaceFirst('faculty:', ''),
                                  )
                                : null;
                          });
                        },
                      )
                    else
                      InputDecorator(
                        decoration: const InputDecoration(labelText: 'คณะ'),
                        child: Text(
                          facultyOptions
                                  .where(
                                    (Faculty item) => item.id == user.facultyId,
                                  )
                                  .firstOrNull
                                  ?.name ??
                              'คณะของผู้ใช้',
                        ),
                      ),
                    const SizedBox(height: 14),
                    _DateTimePickerField(
                      controller: expiredAt,
                      label: 'วันหมดอายุ',
                    ),
                  ],
                ),
                footer: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('ยกเลิก'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: () {
                        if (title.text.trim().isEmpty ||
                            content.text.trim().isEmpty) {
                          return;
                        }
                        Navigator.of(context).pop(
                          AnnouncementEditorResult(
                            announcement: Announcement(
                              id: existing?.id ?? 0,
                              title: title.text.trim(),
                              summary: summary.text.trim(),
                              content: content.text.trim(),
                              author: existing?.author ?? user.name,
                              status: status,
                              priority: priority,
                              targetType: targetType,
                              targetFacultyId: targetFacultyId,
                              targetFacultyName: targetType == 'employee'
                                  ? 'พนักงาน'
                                  : (facultyOptions
                                            .where(
                                              (Faculty item) =>
                                                  item.id == targetFacultyId,
                                            )
                                            .firstOrNull
                                            ?.name ??
                                        'ทุกคน'),
                              createdAt: existing?.createdAt ?? '-',
                              updatedAt: DateTime.now().toIso8601String(),
                              expiredAt: expiredAt.text.trim().isEmpty
                                  ? '-'
                                  : expiredAt.text.trim(),
                              attachments:
                                  existing?.attachments ??
                                  const <AnnouncementAttachment>[],
                            ),
                            imageAttachments: selectedImages
                                .map(PickedAnnouncementAttachment.fromXFile)
                                .toList(),
                            fileAttachments: selectedFiles,
                            clearExistingImages: clearExistingImages,
                            clearExistingFiles: clearExistingFiles,
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
  attachmentUrl.dispose();
  return result;
}

List<Faculty> _uniqueFacultiesById(List<Faculty> faculties) {
  final Set<int> seenIds = <int>{};
  return faculties.where((Faculty item) => seenIds.add(item.id)).toList();
}

String _editorPriority(String? value) {
  switch ((value ?? 'normal').trim().toLowerCase()) {
    case 'urgent':
    case 'high':
      return 'urgent';
    default:
      return 'normal';
  }
}

String _editorStatus(String? value) {
  switch ((value ?? 'draft').trim().toLowerCase()) {
    case 'published':
    case 'publish':
      return 'published';
    case 'pending':
    case 'waiting':
      return 'pending';
    default:
      return 'draft';
  }
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

class _DateTimePickerField extends StatelessWidget {
  const _DateTimePickerField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _pickDateTime(context),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (controller.text.trim().isNotEmpty)
              IconButton(
                tooltip: 'ล้างวันเวลา',
                onPressed: controller.clear,
                icon: const Icon(Icons.close_rounded),
              ),
            IconButton(
              tooltip: 'เลือกวันเวลา',
              onPressed: () => _pickDateTime(context),
              icon: const Icon(Icons.calendar_month_outlined),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDateTime =
        _parseEditorDateTime(controller.text) ?? now;
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (selectedDate == null || !context.mounted) return;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (selectedTime == null) return;

    controller.text = _formatEditorDateTime(
      DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
    );
  }
}

DateTime? _parseEditorDateTime(String value) {
  final String text = value.trim();
  if (text.isEmpty || text == '-') return null;
  return DateTime.tryParse(text);
}

String _formatEditorDateTime(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}:00';
}

bool _isImageUrl(String url) {
  final String path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
  return path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.png') ||
      path.endsWith('.gif') ||
      path.endsWith('.webp') ||
      path.endsWith('.bmp') ||
      path.endsWith('.svg');
}
