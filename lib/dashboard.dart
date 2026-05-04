import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/announcement.dart';
import 'models/app_user.dart';
import 'models/faculty.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/all_news_page.dart';
import 'pages/expired_news_page.dart';
import 'pages/faculties_page.dart';
import 'pages/pending_news_page.dart';
import 'pages/users_page.dart';
import 'login.dart';
import 'services/api_service.dart';
import 'widgets/app_menu.dart';
import 'widgets/dashboard_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.currentUser});

  final AppUser? currentUser;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _api = const ApiService();
  static const Duration _announcementPopupCooldown = Duration(hours: 1);

  late final AppUser currentUser =
      widget.currentUser ??
      const AppUser(id: 0, name: 'Admin', email: '-', role: 'admin');

  bool _showMenu = false;
  bool _isLoading = true;
  bool _isPopupVisible = false;
  String? _error;
  String _activeMenu = 'แดชบอร์ด';

  List<Announcement> _announcements = <Announcement>[];
  List<Map<String, dynamic>> _users = <Map<String, dynamic>>[];
  List<Faculty> _faculties = <Faculty>[];

  @override
  void initState() {
    super.initState();
    if (currentUser.isRecipientOnly) {
      _activeMenu = 'ข่าวทั้งหมด';
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<Announcement> announcements = await _api.fetchAnnouncements(
        visibleFacultyId: currentUser.isAdmin || currentUser.isPr
            ? null
            : currentUser.facultyId,
        visibleRole: currentUser.isAdmin || currentUser.isPr
            ? null
            : currentUser.role,
      );
      final List<Faculty> faculties = await _api.fetchFaculties();
      final List<Map<String, dynamic>> users = currentUser.canManageSystem
          ? await _api.fetchUsers()
          : <Map<String, dynamic>>[];

      if (!mounted) return;
      setState(() {
        _announcements = announcements;
        _faculties = faculties;
        _users = users;
        _isLoading = false;
      });
      _scheduleLatestAnnouncementPopup();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createNews() async {
    final AnnouncementEditorResult? result = await showAnnouncementEditor(
      context: context,
      user: currentUser,
      faculties: _faculties,
    );
    if (result == null) return;

    try {
      final int announcementId = await _api.createAnnouncement(
        result.announcement.toPayload(createdBy: currentUser.id),
      );
      await _syncAnnouncementAttachments(
        announcementId: announcementId,
        images: result.imageAttachments,
        files: result.fileAttachments,
        clearExistingImages: result.clearExistingImages,
        clearExistingFiles: result.clearExistingFiles,
      );
      await _loadData();
    } catch (error) {
      _showActionError(error);
    }
  }

  Future<void> _editNews(Announcement announcement) async {
    final AnnouncementEditorResult? result = await showAnnouncementEditor(
      context: context,
      user: currentUser,
      faculties: _faculties,
      existing: announcement,
    );
    if (result == null) return;

    try {
      await _api.updateAnnouncement(
        announcement.id,
        result.announcement.toPayload(createdBy: currentUser.id),
      );
      await _syncAnnouncementAttachments(
        announcementId: announcement.id,
        images: result.imageAttachments,
        files: result.fileAttachments,
        clearExistingImages: result.clearExistingImages,
        clearExistingFiles: result.clearExistingFiles,
      );
      await _loadData();
    } catch (error) {
      _showActionError(error);
    }
  }

  Future<void> _syncAnnouncementAttachments({
    required int announcementId,
    required List<PickedAnnouncementAttachment> images,
    required List<PickedAnnouncementAttachment> files,
    required bool clearExistingImages,
    required bool clearExistingFiles,
  }) async {
    if (images.isEmpty && files.isEmpty) {
      if (clearExistingImages) {
        await _api.deleteAnnouncementImages(announcementId);
      }
      if (clearExistingFiles) {
        await _api.deleteAnnouncementFiles(announcementId);
      }
      return;
    }

    if (clearExistingImages && images.isEmpty) {
      await _api.deleteAnnouncementImages(announcementId);
    }

    if (clearExistingFiles) {
      await _api.deleteAnnouncementFiles(announcementId);
    }

    for (int index = 0; index < images.length; index += 1) {
      final PickedAnnouncementAttachment image = images[index];
      await _api.uploadAnnouncementAttachment(
        announcementId: announcementId,
        bytes: await image.readAsBytes(),
        fileName: image.fileName,
        replaceExistingImages: clearExistingImages && index == 0,
      );
    }

    for (final PickedAnnouncementAttachment file in files) {
      if (file.isUrl) {
        await _api.createAnnouncementLinkAttachment(
          announcementId: announcementId,
          fileUrl: file.fileName,
        );
      } else {
        await _api.uploadAnnouncementAttachment(
          announcementId: announcementId,
          bytes: await file.readAsBytes(),
          fileName: file.fileName,
        );
      }
    }
  }

  Future<void> _approveNews(Announcement announcement) async {
    await _api.updateAnnouncement(
      announcement.id,
      announcement
          .copyWith(status: 'published')
          .toPayload(createdBy: currentUser.id),
    );
    await _loadData();
  }

  void _showActionError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }

  Future<void> _deleteNews(Announcement announcement) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบข่าว'),
          content: Text('ต้องการลบ "${announcement.title}" ใช่หรือไม่?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await _api.deleteAnnouncement(announcement.id);
    await _loadData();
  }

  Future<void> _saveUser(Map<String, dynamic> payload) async {
    await _api.updateUser(payload);
    await _loadData();
  }

  Future<void> _saveFaculty(int id, Map<String, dynamic> payload) async {
    await _api.updateFaculty(id, payload);
    await _loadData();
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  List<Announcement> get _visibleAnnouncements {
    if (currentUser.isAdmin || currentUser.isPr) return _announcements;
    if (currentUser.isEmployee) {
      return _announcements.where((Announcement item) {
        return item.isAllFaculty || item.isEmployeeTarget;
      }).toList();
    }
    if (currentUser.isTeacher) {
      return _announcements.where((Announcement item) {
        return item.isAllFaculty ||
            (item.isFacultyTarget &&
                item.targetsFaculty(currentUser.facultyId));
      }).toList();
    }
    return _announcements.where((Announcement item) {
      return item.isAllFaculty ||
          (!item.isTeacherTarget &&
              item.isFacultyTarget &&
              item.targetsFaculty(currentUser.facultyId));
    }).toList();
  }

  Future<void> _scheduleLatestAnnouncementPopup() async {
    if (!mounted || _isLoading || _error != null || _isPopupVisible) return;

    final Announcement? latestAnnouncement = _latestAnnouncementForPopup;
    if (latestAnnouncement == null) return;

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String cooldownKey = _announcementPopupCooldownKey;
    final DateTime? closedAt = DateTime.tryParse(
      preferences.getString(cooldownKey) ?? '',
    );
    final DateTime now = DateTime.now();

    if (closedAt != null &&
        now.difference(closedAt) < _announcementPopupCooldown) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _isPopupVisible) return;
      _isPopupVisible = true;
      await showLatestAnnouncementPopup(
        context: context,
        announcement: latestAnnouncement,
      );
      _isPopupVisible = false;

      await preferences.setString(
        cooldownKey,
        DateTime.now().toIso8601String(),
      );
    });
  }

  String get _announcementPopupCooldownKey {
    return 'latest_announcement_popup_closed_at_${currentUser.id}_${currentUser.role}';
  }

  Announcement? get _latestAnnouncementForPopup {
    final List<Announcement> publishedAnnouncements = _visibleAnnouncements
        .where((Announcement item) => item.isPublished && !item.isExpired)
        .toList();
    if (publishedAnnouncements.isEmpty) return null;

    publishedAnnouncements.sort((Announcement a, Announcement b) {
      final DateTime aDate = _announcementTimestamp(a);
      final DateTime bDate = _announcementTimestamp(b);
      final int dateCompare = bDate.compareTo(aDate);
      if (dateCompare != 0) return dateCompare;
      return b.id.compareTo(a.id);
    });

    return publishedAnnouncements.first;
  }

  DateTime _announcementTimestamp(Announcement announcement) {
    return DateTime.tryParse(announcement.createdAt) ??
        DateTime.tryParse(announcement.updatedAt) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  String get _currentUserFacultyName {
    final int? facultyId = currentUser.facultyId;
    if (facultyId == null) return '-';

    for (final Faculty faculty in _faculties) {
      if (faculty.id == facultyId) return faculty.name;
    }

    return 'ไม่พบคณะ';
  }

  List<AppMenuItem> _menuItems() {
    AppMenuItem item(
      IconData icon,
      String label, {
      String? count,
      Color? countColor,
      String? section,
      bool visible = true,
    }) {
      return AppMenuItem(
        icon,
        label,
        active: _activeMenu == label,
        count: count,
        countColor: countColor,
        section: section,
        onTap: visible
            ? () {
                setState(() {
                  _activeMenu = label;
                  _showMenu = false;
                });
              }
            : null,
      );
    }

    return <AppMenuItem>[
      if (!currentUser.isRecipientOnly)
        item(Icons.dashboard_rounded, 'แดชบอร์ด'),
      item(
        Icons.article_outlined,
        'ข่าวทั้งหมด',
        count: '${_visibleAnnouncements.length}',
      ),
      if (currentUser.canManageSystem)
        item(
          Icons.access_time_rounded,
          'รออนุมัติ',
          count:
              '${_announcements.where((Announcement item) => item.isPending).length}',
          countColor: const Color(0xFFF3B7BC),
        ),
      if (currentUser.canManageSystem)
        item(Icons.calendar_today_outlined, 'ข่าวหมดอายุ'),
      if (currentUser.canManageSystem)
        item(
          Icons.people_outline_rounded,
          'จัดการผู้ใช้',
          section: 'จัดการระบบ',
        ),
      if (currentUser.canManageSystem) item(Icons.school_outlined, 'จัดการคณะ'),
    ];
  }

  Widget _activePage() {
    switch (_activeMenu) {
      case 'ข่าวทั้งหมด':
        return AllNewsPage(
          title: 'ข่าวทั้งหมด',
          announcements: _visibleAnnouncements,
          currentUser: currentUser,
          isLoading: _isLoading,
          error: _error,
          onRefresh: _loadData,
          onEdit: _editNews,
          onApprove: _approveNews,
          onDelete: _deleteNews,
        );
      case 'รออนุมัติ':
        return PendingNewsPage(
          announcements: _announcements,
          currentUser: currentUser,
          isLoading: _isLoading,
          error: _error,
          onRefresh: _loadData,
          onEdit: _editNews,
          onApprove: _approveNews,
          onDelete: _deleteNews,
        );
      case 'ข่าวหมดอายุ':
        return ExpiredNewsPage(
          announcements: _announcements,
          currentUser: currentUser,
          isLoading: _isLoading,
          error: _error,
          onRefresh: _loadData,
          onEdit: _editNews,
          onApprove: _approveNews,
          onDelete: _deleteNews,
        );
      case 'จัดการผู้ใช้':
        return UsersPage(
          users: _users,
          faculties: _faculties,
          isLoading: _isLoading,
          error: _error,
          onRefresh: _loadData,
          onSave: _saveUser,
        );
      case 'จัดการคณะ':
        return FacultiesPage(
          faculties: _faculties,
          isLoading: _isLoading,
          error: _error,
          onRefresh: _loadData,
          onSave: _saveFaculty,
        );
      default:
        return AdminDashboardPage(
          currentUser: currentUser,
          announcements: _visibleAnnouncements,
          faculties: _faculties,
          isLoading: _isLoading,
          error: _error,
          onRefresh: _loadData,
          onCreateNews: _createNews,
          onEditNews: _editNews,
          onApproveNews: _approveNews,
          onDeleteNews: _deleteNews,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isDesktop = constraints.maxWidth >= 980;
        final List<AppMenuItem> items = _menuItems();

        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: const Color(0xFFF8F5EE),
                  foregroundColor: const Color(0xFF2D2A24),
                  elevation: 0,
                  leading: IconButton(
                    tooltip: _showMenu ? 'ปิดเมนู' : 'เมนู',
                    onPressed: () => setState(() => _showMenu = !_showMenu),
                    icon: Icon(
                      _showMenu ? Icons.close_rounded : Icons.menu_rounded,
                    ),
                  ),
                  title: Text(_showMenu ? 'เมนู' : _activeMenu),
                  actions: <Widget>[
                    // if (currentUser.canCreateNews)
                    //   IconButton(
                    //     tooltip: 'สร้างข่าว',
                    //     onPressed: _createNews,
                    //     icon: const Icon(Icons.add_rounded),
                    //   ),
                    IconButton(
                      tooltip: 'ออกจากระบบ',
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                ),
          body: SafeArea(
            top: isDesktop,
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 264,
                        child: AppMenu(
                          items: items,
                          userName: currentUser.name,
                          userRole: currentUser.displayRole,
                          userFaculty: _currentUserFacultyName,
                          userInitials: currentUser.initials,
                          onLogout: _logout,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topCenter,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Color(0xFFE0D7C8)),
                            ),
                          ),
                          child: _activePage(),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    alignment: Alignment.topLeft,
                    children: <Widget>[
                      Positioned.fill(child: _activePage()),
                      if (_showMenu) ...<Widget>[
                        Positioned.fill(
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: constraints.maxWidth * 0.85,
                                child: Material(
                                  elevation: 12,
                                  child: AppMenu(
                                    items: items,
                                    userName: currentUser.name,
                                    userRole: currentUser.displayRole,
                                    userFaculty: _currentUserFacultyName,
                                    userInitials: currentUser.initials,
                                    onLogout: _logout,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      setState(() => _showMenu = false),
                                  child: Container(color: Colors.black26),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}
