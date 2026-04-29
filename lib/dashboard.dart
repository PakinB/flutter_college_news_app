import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'widgets/app_menu.dart';

const _apiBaseUrl = 'http://localhost/flutter_college_news_app/php_api';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _showMenu = false;
  String _activeMenu = 'แดชบอร์ด';
  bool _isLoading = true;
  String? _loadError;

  String selectedFilter = 'ทั้งหมด';
  String selectedFaculty = 'ทุกคณะ';
  List<Map<String, dynamic>> users = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> faculties = <Map<String, dynamic>>[];

  final List<String> filters = <String>[
    'ทั้งหมด',
    'เผยแพร่แล้ว',
    'ฉบับร่าง',
    'รออนุมัติ',
    'ด่วน',
  ];

  List<_StatCardData> get statCards {
    final int published = announcements
        .where((_Announcement item) => _isPublishedStatus(item.status))
        .length;
    final int pending = announcements
        .where((_Announcement item) => _isPendingStatus(item.status))
        .length;
    final int urgent = announcements
        .where((_Announcement item) => _isUrgentPriority(item.priority))
        .length;

    return <_StatCardData>[
      _StatCardData(
        'ข่าวทั้งหมด',
        '${announcements.length}',
        'จากฐานข้อมูล',
        const Color(0xFF232323),
      ),
      _StatCardData(
        'เผยแพร่แล้ว',
        '$published',
        announcements.isEmpty
            ? '0% ของทั้งหมด'
            : '${((published / announcements.length) * 100).round()}% ของทั้งหมด',
        const Color(0xFF5E9734),
      ),
      _StatCardData(
        'รออนุมัติ',
        '$pending',
        'ต้องดำเนินการ',
        const Color(0xFFAF7320),
      ),
      _StatCardData(
        'ข่าวด่วน',
        '$urgent',
        'กำลังแสดงอยู่',
        const Color(0xFFC74A47),
      ),
    ];
  }

  final List<_NotificationItem> notifications = const <_NotificationItem>[
    _NotificationItem(
      title: 'มีข่าวด่วนใหม่: ประกาศปิดมหาวิทยาลัยกรณีฉุกเฉิน',
      time: '5 นาทีที่แล้ว',
      highlighted: true,
    ),
    _NotificationItem(
      title: 'มีข่าวรออนุมัติ: สัมมนาวิชาการ ธุรกิจยุคดิจิทัล',
      time: '1 ชั่วโมงที่แล้ว',
      highlighted: true,
    ),
    _NotificationItem(
      title: 'ข่าวฉบับร่างรอการอนุมัติ: ตารางสอบกลางภาค',
      time: '3 ชั่วโมงที่แล้ว',
    ),
    _NotificationItem(
      title: 'ข่าวหมดอายุ: ประกาศรับสมัคร TA ประจำปี 2567',
      time: 'เมื่อวาน',
    ),
    _NotificationItem(
      title: 'ผู้ใช้ใหม่ถูกเพิ่มเข้าระบบ: นางสาวพิมพ์ใจ รักเรียน (นักศึกษา)',
      time: 'เมื่อวาน',
    ),
  ];

  List<_Announcement> announcements = <_Announcement>[
    _Announcement(
      title: 'ประกาศปิดมหาวิทยาลัยกรณีฉุกเฉิน วันที่ 30 เมษายน 2568',
      summary: 'ประกาศสำคัญกรณีสภาพอากาศแปรปรวน',
      body:
          'เนื่องจากสภาพอากาศแปรปรวนและมีพายุเข้าพื้นที่ มหาวิทยาลัยจะปิดทำการชั่วคราวในวันที่ 30 เมษายน 2568',
      author: 'กองกลางมหาวิทยาลัย',
      updatedAt: '28 เม.ย. 68',
      expiresAt: '1 พ.ค. 68',
      status: 'เผยแพร่แล้ว',
      priority: 'ด่วน',
      faculty: 'ทั้งมหาวิทยาลัย',
      tags: const <_Tag>[
        _Tag('ด่วน', Color(0xFFF6C5C3), Color(0xFF9A3835)),
        _Tag('เผยแพร่แล้ว', Color(0xFFCDE8B3), Color(0xFF507A1A)),
        _Tag('ทั้งมหาวิทยาลัย', Color(0xFFBCE8D6), Color(0xFF1C7E65)),
      ],
      accent: const Color(0xFF5B57D8),
      actions: const <String>['แก้ไข', 'ลบ'],
    ),
    _Announcement(
      title: 'กำหนดการสอบกลางภาค ภาคเรียนที่ 1/2568',
      summary: 'ตารางสอบสำหรับนักศึกษาคณะวิศวกรรมศาสตร์',
      body:
          'ตารางสอบกลางภาคสำหรับนักศึกษาคณะวิศวกรรมศาสตร์ทุกชั้นปี โปรดตรวจสอบห้องสอบและเวลาสอบให้ถูกต้อง',
      author: 'ผศ.ดร. วิชัย มีสุข',
      updatedAt: '27 เม.ย. 68',
      expiresAt: '-',
      status: 'ฉบับร่าง',
      priority: 'ปกติ',
      faculty: 'คณะวิศวกรรมศาสตร์',
      tags: const <_Tag>[
        _Tag('ปกติ', Color(0xFFE3DED4), Color(0xFF665E4B)),
        _Tag('ฉบับร่าง', Color(0xFFF1C66E), Color(0xFF855500)),
        _Tag('คณะวิศวกรรมศาสตร์', Color(0xFFBBD5F2), Color(0xFF295C94)),
      ],
      actions: const <String>['แก้ไข', 'อนุมัติ'],
    ),
    _Announcement(
      title:
          'รับสมัครนักศึกษาเข้าร่วมโครงการแลกเปลี่ยนต่างประเทศ ประจำปีการศึกษา 2568',
      summary: 'เปิดรับสมัครนักศึกษาที่สนใจเข้าร่วมโครงการ',
      body:
          'มหาวิทยาลัยเปิดรับสมัครนักศึกษาที่สนใจเข้าร่วมโครงการแลกเปลี่ยนกับมหาวิทยาลัยชั้นนำใน 12 ประเทศ',
      author: 'กองวิเทศสัมพันธ์',
      updatedAt: '25 เม.ย. 68',
      expiresAt: '31 พ.ค. 68',
      status: 'เผยแพร่แล้ว',
      priority: 'ปกติ',
      faculty: 'ทั้งมหาวิทยาลัย',
      tags: const <_Tag>[
        _Tag('ปกติ', Color(0xFFE3DED4), Color(0xFF665E4B)),
        _Tag('เผยแพร่แล้ว', Color(0xFFCDE8B3), Color(0xFF507A1A)),
        _Tag('ทั้งมหาวิทยาลัย', Color(0xFFBCE8D6), Color(0xFF1C7E65)),
      ],
      actions: const <String>['แก้ไข', 'ลบ'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final List<dynamic> announcementRows = await _fetchApiList(
        'announcements/index.php',
      );
      final List<dynamic> userRows = await _fetchApiList('users/get_users.php');
      final List<dynamic> facultyRows = await _fetchApiList(
        'faculties/index.php',
      );

      if (!mounted) return;

      setState(() {
        announcements = announcementRows
            .whereType<Map<String, dynamic>>()
            .map(_Announcement.fromApi)
            .toList();
        users = userRows.whereType<Map<String, dynamic>>().toList();
        faculties = facultyRows.whereType<Map<String, dynamic>>().toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> _fetchApiList(String path) async {
    final Uri url = Uri.parse('$_apiBaseUrl/$path');
    final http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Request failed: ${response.statusCode}');
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw Exception(body['message'] ?? 'API error');
    }

    return (body['data'] as List<dynamic>? ?? <dynamic>[]);
  }

  List<_Announcement> get filteredAnnouncements {
    if (selectedFilter == 'ทั้งหมด') {
      return announcements;
    }

    return announcements.where((_Announcement item) {
      if (selectedFilter == 'ด่วน') {
        return _isUrgentPriority(item.priority);
      }
      if (selectedFilter == 'เผยแพร่แล้ว') {
        return _isPublishedStatus(item.status);
      }
      if (selectedFilter == 'รออนุมัติ') {
        return _isPendingStatus(item.status);
      }
      if (selectedFilter == 'ฉบับร่าง') {
        return _isDraftStatus(item.status);
      }
      return item.status == selectedFilter;
    }).toList();
  }

  Future<void> _showNotificationsDialog() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black45,
      builder: (BuildContext context) {
        return _DashboardDialog(
          title: 'การแจ้งเตือน',
          maxWidth: 640,
          body: Column(
            children: notifications.map((_NotificationItem item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.highlighted
                              ? const Color(0xFF5B57D8)
                              : const Color(0xFFC9C7C2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2A24),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6E6A61),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ปิด'),
              ),
              const SizedBox(width: 10),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2D2A24),
                  side: const BorderSide(color: Color(0xFFD7CEBE)),
                ),
                child: const Text('ทำเครื่องหมายว่าอ่านแล้วทั้งหมด'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCreateNewsDialog() async {
    final _Announcement? created = await _showAnnouncementEditor();
    if (created == null) {
      return;
    }

    setState(() {
      announcements.insert(0, created);
    });
  }

  Future<void> _showEditNewsDialog(int index) async {
    final _Announcement? updated = await _showAnnouncementEditor(
      existing: announcements[index],
    );
    if (updated == null) {
      return;
    }

    setState(() {
      announcements[index] = updated;
    });
  }

  Future<_Announcement?> _showAnnouncementEditor({
    _Announcement? existing,
  }) async {
    final bool isEdit = existing != null;
    final TextEditingController titleController = TextEditingController(
      text: existing?.title ?? '',
    );
    final TextEditingController summaryController = TextEditingController(
      text: existing?.summary ?? '',
    );
    final TextEditingController bodyController = TextEditingController(
      text: existing?.body ?? '',
    );

    String priority = existing?.priority ?? 'ปกติ';
    String faculty = existing?.faculty ?? 'ทั้งมหาวิทยาลัย';
    String publishDate = existing == null ? '04/28/2025' : '04/28/2025';
    String expireDate = existing == null ? '05/28/2025' : '05/28/2025';

    final _Announcement? result = await showDialog<_Announcement>(
      context: context,
      barrierColor: Colors.black45,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (
                BuildContext context,
                void Function(void Function()) setDialogState,
              ) {
                return _DashboardDialog(
                  title: isEdit ? 'แก้ไขข่าว' : 'สร้างข่าวใหม่',
                  maxWidth: 680,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _DialogFieldLabel(
                        isEdit ? 'หัวข้อข่าว *' : 'หัวข้อข่าว *',
                      ),
                      _DialogTextField(
                        controller: titleController,
                        hintText: 'กรอกหัวข้อข่าว...',
                      ),
                      if (!isEdit) ...<Widget>[
                        const SizedBox(height: 14),
                        const _DialogFieldLabel('สรุปข่าว'),
                        _DialogTextField(
                          controller: summaryController,
                          hintText: 'สรุปสั้น ๆ (แสดงในหน้ารายการ)',
                        ),
                      ],
                      const SizedBox(height: 14),
                      const _DialogFieldLabel('เนื้อหา *'),
                      _DialogTextField(
                        controller: bodyController,
                        hintText: 'กรอกเนื้อหาข่าว...',
                        minLines: isEdit ? 4 : 5,
                        maxLines: isEdit ? 4 : 5,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _DialogDropdown(
                              label: 'ความสำคัญ',
                              value: priority,
                              items: const <String>['ปกติ', 'ด่วน'],
                              onChanged: (String? value) {
                                if (value == null) {
                                  return;
                                }
                                setDialogState(() => priority = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _DialogDropdown(
                              label: 'กลุ่มเป้าหมาย',
                              value: faculty,
                              items: const <String>[
                                'ทั้งมหาวิทยาลัย',
                                'คณะวิศวกรรมศาสตร์',
                                'คณะบริหารธุรกิจ',
                              ],
                              onChanged: (String? value) {
                                if (value == null) {
                                  return;
                                }
                                setDialogState(() => faculty = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (!isEdit) ...<Widget>[
                        const SizedBox(height: 14),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _DialogDateField(
                                label: 'วันที่เผยแพร่',
                                value: publishDate,
                                onTap: () => setDialogState(
                                  () => publishDate = '04/28/2025',
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _DialogDateField(
                                label: 'วันหมดอายุ',
                                value: expireDate,
                                onTap: () => setDialogState(
                                  () => expireDate = '05/28/2025',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const _DialogFieldLabel('แนบไฟล์'),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F2E7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE3D9C6)),
                          ),
                          child: const Row(
                            children: <Widget>[
                              Icon(Icons.add_rounded, size: 22),
                              SizedBox(width: 12),
                              Text(
                                'คลิกเพื่อเลือกไฟล์ (PDF, รูปภาพ)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      FilledButton.tonal(
                        onPressed: () {
                          final String title = titleController.text.trim();
                          final String body = bodyController.text.trim();

                          if (title.isEmpty || body.isEmpty) {
                            return;
                          }

                          Navigator.of(context).pop(
                            _buildAnnouncementFromForm(
                              existing: existing,
                              title: title,
                              summary: summaryController.text.trim().isEmpty
                                  ? body
                                  : summaryController.text.trim(),
                              body: body,
                              priority: priority,
                              faculty: faculty,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2D2A24),
                          side: const BorderSide(color: Color(0xFFD7CEBE)),
                        ),
                        child: Text(isEdit ? 'บันทึก' : 'สร้างข่าว'),
                      ),
                    ],
                  ),
                );
              },
        );
      },
    );

    titleController.dispose();
    summaryController.dispose();
    bodyController.dispose();
    return result;
  }

  _Announcement _buildAnnouncementFromForm({
    _Announcement? existing,
    required String title,
    required String summary,
    required String body,
    required String priority,
    required String faculty,
  }) {
    final String status = existing?.status ?? 'ฉบับร่าง';
    return _Announcement(
      title: title,
      summary: summary,
      body: body,
      author: existing?.author ?? 'Admin',
      updatedAt: '28 เม.ย. 68',
      expiresAt: existing?.expiresAt ?? '31 พ.ค. 68',
      status: status,
      priority: priority,
      faculty: faculty,
      tags: _buildTags(status: status, priority: priority, faculty: faculty),
      accent: priority == 'ด่วน' ? const Color(0xFF5B57D8) : null,
      actions: existing?.actions ?? const <String>['แก้ไข', 'ลบ'],
    );
  }

  List<_Tag> _buildTags({
    required String status,
    required String priority,
    required String faculty,
  }) {
    return <_Tag>[
      priority == 'ด่วน'
          ? const _Tag('ด่วน', Color(0xFFF6C5C3), Color(0xFF9A3835))
          : const _Tag('ปกติ', Color(0xFFE3DED4), Color(0xFF665E4B)),
      status == 'เผยแพร่แล้ว'
          ? const _Tag('เผยแพร่แล้ว', Color(0xFFCDE8B3), Color(0xFF507A1A))
          : status == 'รออนุมัติ'
          ? const _Tag('รออนุมัติ', Color(0xFFF7D4A7), Color(0xFF9C5B00))
          : const _Tag('ฉบับร่าง', Color(0xFFF1C66E), Color(0xFF855500)),
      faculty == 'ทั้งมหาวิทยาลัย'
          ? const _Tag('ทั้งมหาวิทยาลัย', Color(0xFFBCE8D6), Color(0xFF1C7E65))
          : const _Tag(
              'คณะวิศวกรรมศาสตร์',
              Color(0xFFBBD5F2),
              Color(0xFF295C94),
            ),
    ];
  }

  Future<void> _showDeleteDialog(int index) async {
    final _Announcement announcement = announcements[index];
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      builder: (BuildContext context) {
        return _DashboardDialog(
          title: 'ยืนยันการลบข่าว',
          titleColor: const Color(0xFFC74A47),
          maxWidth: 640,
          body: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Noto Sans Thai',
                fontSize: 16,
                height: 1.7,
                color: Color(0xFF2D2A24),
              ),
              children: <TextSpan>[
                const TextSpan(text: 'คุณต้องการลบข่าว '),
                TextSpan(
                  text: '"${announcement.title}"',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(
                  text: ' ใช่หรือไม่?\n\nการลบข่าวจะไม่สามารถกู้คืนได้',
                ),
              ],
            ),
          ),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('ยกเลิก'),
              ),
              const SizedBox(width: 10),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2D2A24),
                  side: const BorderSide(color: Color(0xFFD7CEBE)),
                ),
                child: const Text('ยืนยันการลบ'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        announcements.removeAt(index);
      });
    }
  }

  void _approveAnnouncement(int index) {
    final _Announcement announcement = announcements[index];
    setState(() {
      announcements[index] = announcement.copyWith(
        status: 'เผยแพร่แล้ว',
        tags: _buildTags(
          status: 'เผยแพร่แล้ว',
          priority: announcement.priority,
          faculty: announcement.faculty,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isDesktop = constraints.maxWidth >= 980;
        final bool isTablet = constraints.maxWidth >= 700;
        final List<AppMenuItem> menuItems = _buildAppMenuItems(
          context,
          activeLabel: _activeMenu,
          onSelected: (String label) {
            setState(() {
              _activeMenu = label;
              _showMenu = false;
            });
          },
        );

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
                  title: Text(
                    _showMenu ? 'เมนู' : _activeMenu,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  actions: <Widget>[
                    IconButton(
                      tooltip: 'การแจ้งเตือน',
                      onPressed: _showNotificationsDialog,
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    IconButton(
                      tooltip: 'เพิ่มเติม',
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz_rounded),
                    ),
                  ],
                ),
          body: SafeArea(
            top: isDesktop,
            child: !isDesktop && _showMenu
                ? AppMenu(items: menuItems)
                : Row(
                    children: <Widget>[
                      if (isDesktop)
                        SizedBox(width: 264, child: AppMenu(items: menuItems)),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Color(0xFFE0D7C8)),
                            ),
                          ),
                          child: _activeMenu == 'แดชบอร์ด'
                              ? _DashboardContent(
                                  isDesktop: isDesktop,
                                  isTablet: isTablet,
                                  statCards: statCards,
                                  filters: filters,
                                  selectedFilter: selectedFilter,
                                  selectedFaculty: selectedFaculty,
                                  filteredAnnouncements: filteredAnnouncements,
                                  announcements: announcements,
                                  isLoading: _isLoading,
                                  loadError: _loadError,
                                  onRefresh: _loadDashboardData,
                                  onNotificationsTap: _showNotificationsDialog,
                                  onCreateTap: _showCreateNewsDialog,
                                  onFilterChanged: (String value) {
                                    setState(() => selectedFilter = value);
                                  },
                                  onActionPressed:
                                      (int actualIndex, String action) {
                                        if (action == 'แก้ไข') {
                                          _showEditNewsDialog(actualIndex);
                                        } else if (action == 'ลบ') {
                                          _showDeleteDialog(actualIndex);
                                        } else if (action == 'อนุมัติ') {
                                          _approveAnnouncement(actualIndex);
                                        }
                                      },
                                )
                              : _MenuPlaceholderContent(
                                  title: _activeMenu,
                                  icon: _menuIconFor(_activeMenu),
                                  announcements: announcements,
                                  users: users,
                                  faculties: faculties,
                                  isLoading: _isLoading,
                                  loadError: _loadError,
                                  onRefresh: _loadDashboardData,
                                ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

List<AppMenuItem> _buildAppMenuItems(
  BuildContext context, {
  required String activeLabel,
  ValueChanged<String>? onSelected,
}) {
  AppMenuItem item(
    IconData icon,
    String label, {
    String? count,
    Color? countColor,
    String? section,
  }) {
    return AppMenuItem(
      icon,
      label,
      active: activeLabel == label,
      count: count,
      countColor: countColor,
      section: section,
      onTap: activeLabel == label
          ? null
          : () {
              if (onSelected != null) {
                onSelected(label);
                return;
              }
              _openMenuDestination(context, label);
            },
    );
  }

  return <AppMenuItem>[
    item(Icons.dashboard_rounded, 'แดชบอร์ด'),
    item(Icons.article_outlined, 'ข่าวทั้งหมด', count: '24'),
    item(
      Icons.access_time_rounded,
      'รออนุมัติ',
      count: '5',
      countColor: const Color(0xFFF3B7BC),
    ),
    item(Icons.calendar_today_outlined, 'ข่าวหมดอายุ'),
    item(Icons.people_outline_rounded, 'จัดการผู้ใช้', section: 'จัดการระบบ'),
    item(Icons.school_outlined, 'จัดการคณะ'),
  ];
}

void _openMenuDestination(BuildContext context, String label) {
  final Widget page = label == 'แดชบอร์ด'
      ? const DashboardPage()
      : _MenuDestinationPage(title: label, icon: _menuIconFor(label));

  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute<void>(builder: (_) => page));
}

IconData _menuIconFor(String label) {
  switch (label) {
    case 'ข่าวทั้งหมด':
      return Icons.article_outlined;
    case 'รออนุมัติ':
      return Icons.access_time_rounded;
    case 'ข่าวหมดอายุ':
      return Icons.calendar_today_outlined;
    case 'จัดการผู้ใช้':
      return Icons.people_outline_rounded;
    case 'จัดการคณะ':
      return Icons.school_outlined;
    default:
      return Icons.dashboard_rounded;
  }
}

bool _isPublishedStatus(String value) {
  final String normalized = value.toLowerCase();
  return value == 'เผยแพร่แล้ว' ||
      normalized == 'published' ||
      normalized == 'publish';
}

bool _isPendingStatus(String value) {
  final String normalized = value.toLowerCase();
  return value == 'รออนุมัติ' ||
      normalized == 'pending' ||
      normalized == 'waiting';
}

bool _isDraftStatus(String value) {
  final String normalized = value.toLowerCase();
  return value == 'ฉบับร่าง' || normalized == 'draft';
}

bool _isUrgentPriority(String value) {
  final String normalized = value.toLowerCase();
  return value == 'ด่วน' || normalized == 'urgent' || normalized == 'high';
}

List<_Tag> _makeTags({
  required String status,
  required String priority,
  required String faculty,
}) {
  return <_Tag>[
    _isUrgentPriority(priority)
        ? const _Tag('ด่วน', Color(0xFFF6C5C3), Color(0xFF9A3835))
        : const _Tag('ปกติ', Color(0xFFE3DED4), Color(0xFF665E4B)),
    _isPublishedStatus(status)
        ? const _Tag('เผยแพร่แล้ว', Color(0xFFCDE8B3), Color(0xFF507A1A))
        : _isPendingStatus(status)
        ? const _Tag('รออนุมัติ', Color(0xFFF7D4A7), Color(0xFF9C5B00))
        : const _Tag('ฉบับร่าง', Color(0xFFF1C66E), Color(0xFF855500)),
    faculty == 'ทั้งมหาวิทยาลัย' || faculty == 'all'
        ? const _Tag('ทั้งมหาวิทยาลัย', Color(0xFFBCE8D6), Color(0xFF1C7E65))
        : _Tag(faculty, const Color(0xFFBBD5F2), const Color(0xFF295C94)),
  ];
}

String _displayStatus(String value) {
  if (_isPublishedStatus(value)) return 'เผยแพร่แล้ว';
  if (_isPendingStatus(value)) return 'รออนุมัติ';
  if (_isDraftStatus(value)) return 'ฉบับร่าง';
  return value.isEmpty ? '-' : value;
}

String _displayPriority(String value) {
  if (_isUrgentPriority(value)) return 'ด่วน';
  if (value.toLowerCase() == 'normal') return 'ปกติ';
  return value.isEmpty ? '-' : value;
}

String _textValue(dynamic value, {String fallback = '-'}) {
  if (value == null) return fallback;
  final String text = '$value'.trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
  return text;
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.isDesktop,
    required this.isTablet,
    required this.statCards,
    required this.filters,
    required this.selectedFilter,
    required this.selectedFaculty,
    required this.filteredAnnouncements,
    required this.announcements,
    required this.isLoading,
    required this.loadError,
    required this.onRefresh,
    required this.onNotificationsTap,
    required this.onCreateTap,
    required this.onFilterChanged,
    required this.onActionPressed,
  });

  final bool isDesktop;
  final bool isTablet;
  final List<_StatCardData> statCards;
  final List<String> filters;
  final String selectedFilter;
  final String selectedFaculty;
  final List<_Announcement> filteredAnnouncements;
  final List<_Announcement> announcements;
  final bool isLoading;
  final String? loadError;
  final Future<void> Function() onRefresh;
  final VoidCallback onNotificationsTap;
  final VoidCallback onCreateTap;
  final ValueChanged<String> onFilterChanged;
  final void Function(int actualIndex, String action) onActionPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadError != null) {
      return _ErrorState(message: loadError!, onRefresh: onRefresh);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 20 : 14,
        16,
        isTablet ? 20 : 14,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ResponsiveTopBar(
            isDesktop: isDesktop,
            onNotificationsTap: onNotificationsTap,
            onCreateTap: onCreateTap,
          ),
          const SizedBox(height: 18),
          _StatsGrid(
            statCards: statCards,
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
          const SizedBox(height: 16),
          _FilterRow(
            filters: filters,
            selectedFilter: selectedFilter,
            selectedFaculty: selectedFaculty,
            onFilterChanged: onFilterChanged,
          ),
          const SizedBox(height: 16),
          const Text(
            'ข่าวประกาศ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D2A24),
            ),
          ),
          const SizedBox(height: 12),
          if (filteredAnnouncements.isEmpty)
            const _EmptyState(message: 'ยังไม่มีข่าวประกาศในฐานข้อมูล')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAnnouncements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int visibleIndex) {
                final _Announcement item = filteredAnnouncements[visibleIndex];
                final int actualIndex = announcements.indexOf(item);

                return _AnnouncementCard(
                  announcement: item,
                  compact: !isTablet,
                  onActionPressed: (String action) {
                    onActionPressed(actualIndex, action);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MenuPlaceholderContent extends StatelessWidget {
  const _MenuPlaceholderContent({
    required this.title,
    required this.icon,
    required this.announcements,
    required this.users,
    required this.faculties,
    required this.isLoading,
    required this.loadError,
    required this.onRefresh,
  });

  final String title;
  final IconData icon;
  final List<_Announcement> announcements;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> faculties;
  final bool isLoading;
  final String? loadError;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadError != null) {
      return _ErrorState(message: loadError!, onRefresh: onRefresh);
    }

    if (title == 'ข่าวทั้งหมด') {
      return _AnnouncementListContent(
        title: title,
        announcements: announcements,
      );
    }

    if (title == 'รออนุมัติ') {
      return _AnnouncementListContent(
        title: title,
        announcements: announcements
            .where((_Announcement item) => _isPendingStatus(item.status))
            .toList(),
      );
    }

    if (title == 'ข่าวหมดอายุ') {
      return _AnnouncementListContent(
        title: title,
        announcements: announcements
            .where(
              (_Announcement item) =>
                  item.expiresAt != '-' && item.expiresAt.isNotEmpty,
            )
            .toList(),
      );
    }

    if (title == 'จัดการผู้ใช้') {
      return _MapListContent(
        title: title,
        icon: icon,
        emptyMessage: 'ยังไม่มีผู้ใช้ในฐานข้อมูล',
        rows: users,
        titleBuilder: (Map<String, dynamic> row) => '${row['name'] ?? '-'}',
        lineBuilder: (Map<String, dynamic> row) => <String>[
          'อีเมล: ${row['email'] ?? '-'}',
          'บทบาท: ${row['role'] ?? '-'}',
          'คณะ ID: ${row['faculty_id'] ?? '-'}',
        ],
      );
    }

    if (title == 'จัดการคณะ') {
      return _MapListContent(
        title: title,
        icon: icon,
        emptyMessage: 'ยังไม่มีคณะในฐานข้อมูล',
        rows: faculties,
        titleBuilder: (Map<String, dynamic> row) => '${row['name'] ?? '-'}',
        lineBuilder: (Map<String, dynamic> row) => <String>[
          'รายละเอียด: ${row['description'] ?? '-'}',
          'สร้างเมื่อ: ${row['created_at'] ?? '-'}',
        ],
      );
    }

    return _MenuPlaceholderMessage(title: title, icon: icon);
  }
}

class _MenuPlaceholderMessage extends StatelessWidget {
  const _MenuPlaceholderMessage({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 56, color: const Color(0xFF4E49B7)),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D2A24),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'หน้านี้พร้อมเชื่อมต่อข้อมูลจริงในขั้นตอนถัดไป',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF6E6A61)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRefresh});

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF433F36)),
            ),
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBD0BF)),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.inbox_outlined, color: Color(0xFF777267)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF676257)),
          ),
        ],
      ),
    );
  }
}

class _SimpleDataCard extends StatelessWidget {
  const _SimpleDataCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBD0BF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D2A24),
            ),
          ),
          const SizedBox(height: 8),
          ...lines.map(
            (String line) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                line,
                style: const TextStyle(color: Color(0xFF676257)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementListContent extends StatelessWidget {
  const _AnnouncementListContent({
    required this.title,
    required this.announcements,
  });

  final String title;
  final List<_Announcement> announcements;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D2A24),
            ),
          ),
          const SizedBox(height: 12),
          if (announcements.isEmpty)
            const _EmptyState(message: 'ยังไม่มีข้อมูลในหน้านี้')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: announcements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                return _AnnouncementCard(
                  announcement: announcements[index],
                  compact: true,
                  onActionPressed: (_) {},
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MapListContent extends StatelessWidget {
  const _MapListContent({
    required this.title,
    required this.icon,
    required this.emptyMessage,
    required this.rows,
    required this.titleBuilder,
    required this.lineBuilder,
  });

  final String title;
  final IconData icon;
  final String emptyMessage;
  final List<Map<String, dynamic>> rows;
  final String Function(Map<String, dynamic> row) titleBuilder;
  final List<String> Function(Map<String, dynamic> row) lineBuilder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: const Color(0xFF4E49B7)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D2A24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            _EmptyState(message: emptyMessage)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> row = rows[index];
                return _SimpleDataCard(
                  title: titleBuilder(row),
                  lines: lineBuilder(row),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MenuDestinationPage extends StatefulWidget {
  const _MenuDestinationPage({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  State<_MenuDestinationPage> createState() => _MenuDestinationPageState();
}

class _MenuDestinationPageState extends State<_MenuDestinationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isDesktop = constraints.maxWidth >= 980;
        final List<AppMenuItem> menuItems = _buildAppMenuItems(
          context,
          activeLabel: widget.title,
        );

        return Scaffold(
          key: _scaffoldKey,
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: const Color(0xFFF8F5EE),
                  foregroundColor: const Color(0xFF2D2A24),
                  elevation: 0,
                  leading: IconButton(
                    tooltip: 'เมนู',
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                  ),
                  title: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
          endDrawer: isDesktop
              ? null
              : Drawer(
                  child: SafeArea(
                    child: AppMenu(items: menuItems, closeOnTap: true),
                  ),
                ),
          body: SafeArea(
            top: isDesktop,
            child: Row(
              children: <Widget>[
                if (isDesktop)
                  SizedBox(width: 264, child: AppMenu(items: menuItems)),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFFE0D7C8)),
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                widget.icon,
                                size: 56,
                                color: const Color(0xFF4E49B7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D2A24),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'หน้านี้พร้อมเชื่อมต่อข้อมูลจริงในขั้นตอนถัดไป',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6E6A61),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResponsiveTopBar extends StatelessWidget {
  const _ResponsiveTopBar({
    required this.isDesktop,
    required this.onNotificationsTap,
    required this.onCreateTap,
  });

  final bool isDesktop;
  final VoidCallback onNotificationsTap;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 420;
        final bool isPhone = availableWidth < 560;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (isDesktop) ...<Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'แดชบอร์ด',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _IconSurface(
                    size: isPhone ? 46 : 52,
                    overlayDot: true,
                    child: IconButton(
                      tooltip: 'การแจ้งเตือน',
                      onPressed: onNotificationsTap,
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const _IconSurface(
                    size: 46,
                    fillColor: Colors.white,
                    child: Icon(Icons.more_horiz_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Flex(
              direction: isPhone ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (isPhone)
                  const _SearchBox()
                else
                  const Expanded(child: _SearchBox()),
                SizedBox(width: isPhone ? 0 : 12, height: isPhone ? 10 : 0),
                SizedBox(
                  width: isPhone ? double.infinity : null,
                  child: FilledButton.icon(
                    onPressed: onCreateTap,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('สร้างข่าวใหม่'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: const Color(0xFF4E49B7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8CEBC)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.search_rounded, size: 20, color: Color(0xFF6C685D)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'ค้นหาข่าว...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Color(0xFF8A857A), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.statCards,
    required this.isDesktop,
    required this.isTablet,
  });

  final List<_StatCardData> statCards;
  final bool isDesktop;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cardWidth = isDesktop
            ? (constraints.maxWidth - 36) / 4
            : (isTablet
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: statCards.map((_StatCardData item) {
            return SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF615C52),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: item.valueColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.caption,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A7568),
                      ),
                    ),
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

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filters,
    required this.selectedFilter,
    required this.selectedFaculty,
    required this.onFilterChanged,
  });

  final List<String> filters;
  final String selectedFilter;
  final String selectedFaculty;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        ...filters.map(
          (String filter) => ChoiceChip(
            label: Text(filter),
            selected: selectedFilter == filter,
            onSelected: (_) => onFilterChanged(filter),
            labelStyle: TextStyle(
              color: selectedFilter == filter
                  ? const Color(0xFF4B47C3)
                  : const Color(0xFF59554B),
              fontWeight: FontWeight.w600,
            ),
            showCheckmark: false,
            side: const BorderSide(color: Color(0xFFD1C6B3)),
            selectedColor: const Color(0xFFE7E3FF),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'คณะ:',
          style: TextStyle(fontSize: 15, color: Color(0xFF5E5A50)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEAE7FF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFCCC4FF)),
          ),
          child: Text(
            selectedFaculty,
            style: const TextStyle(
              color: Color(0xFF4B47C3),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.compact,
    required this.onActionPressed,
  });

  final _Announcement announcement;
  final bool compact;
  final ValueChanged<String> onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    compact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: announcement.tags
                                    .map((_Tag tag) => _TagPill(tag: tag))
                                    .toList(),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                announcement.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: announcement.tags
                                      .map((_Tag tag) => _TagPill(tag: tag))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  announcement.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 12),
                    Text(
                      announcement.body,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: Color(0xFF433F36),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 14,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          announcement.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B564C),
                          ),
                        ),
                        Text(
                          'แก้ไขล่าสุด: ${announcement.updatedAt}',
                          style: const TextStyle(color: Color(0xFF676257)),
                        ),
                        Text(
                          'หมดอายุ: ${announcement.expiresAt}',
                          style: const TextStyle(color: Color(0xFF676257)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.end,
                      children: announcement.actions.map((String action) {
                        return OutlinedButton(
                          onPressed: () => onActionPressed(action),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            side: const BorderSide(color: Color(0xFFCBC0AF)),
                            foregroundColor: const Color(0xFF37342E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            action,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.tag});

  final _Tag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tag.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag.label,
        style: TextStyle(
          color: tag.foreground,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DashboardDialog extends StatelessWidget {
  const _DashboardDialog({
    required this.title,
    required this.body,
    required this.footer,
    this.maxWidth = 680,
    this.titleColor = const Color(0xFF2D2A24),
  });

  final String title;
  final Widget body;
  final Widget footer;
  final double maxWidth;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F5EE),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD9CFBE)),
                          ),
                          child: const Icon(Icons.close_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2D8C8)),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                    child: body,
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2D8C8)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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

class _DialogFieldLabel extends StatelessWidget {
  const _DialogFieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.controller,
    required this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9CFBE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9CFBE)),
        ),
      ),
    );
  }
}

class _DialogDropdown extends StatelessWidget {
  const _DialogDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _DialogFieldLabel(label),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          items: items
              .map(
                (String item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD9CFBE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD9CFBE)),
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogDateField extends StatelessWidget {
  const _DialogDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _DialogFieldLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD9CFBE)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(value, style: const TextStyle(fontSize: 15)),
                ),
                const Icon(Icons.calendar_today_outlined, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IconSurface extends StatelessWidget {
  const _IconSurface({
    required this.child,
    this.size = 46,
    this.fillColor = Colors.white,
    this.overlayDot = false,
  });

  final Widget child;
  final double size;
  final Color fillColor;
  final bool overlayDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8CEBC)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          child,
          if (overlayDot)
            Positioned(
              top: 10,
              right: 11,
              child: Container(
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFFE14F45),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCardData {
  const _StatCardData(this.label, this.value, this.caption, this.valueColor);

  final String label;
  final String value;
  final String caption;
  final Color valueColor;
}

class _Announcement {
  const _Announcement({
    required this.title,
    required this.summary,
    required this.body,
    required this.author,
    required this.updatedAt,
    required this.expiresAt,
    required this.status,
    required this.priority,
    required this.faculty,
    required this.tags,
    required this.actions,
    this.accent,
  });

  final String title;
  final String summary;
  final String body;
  final String author;
  final String updatedAt;
  final String expiresAt;
  final String status;
  final String priority;
  final String faculty;
  final List<_Tag> tags;
  final List<String> actions;
  final Color? accent;

  factory _Announcement.fromApi(Map<String, dynamic> row) {
    final String status = _displayStatus(_textValue(row['status']));
    final String priority = _displayPriority(_textValue(row['priority']));
    final String faculty = _textValue(
      row['target_faculty_name'] ?? row['faculty'] ?? row['target_type'],
      fallback: 'ทุกคณะ',
    );

    return _Announcement(
      title: _textValue(row['title']),
      summary: _textValue(row['summary'], fallback: ''),
      body: _textValue(row['content'] ?? row['body'] ?? row['summary']),
      author: _textValue(row['creator_name'] ?? row['created_by']),
      updatedAt: _textValue(row['updated_at'] ?? row['created_at']),
      expiresAt: _textValue(row['expired_at']),
      status: status,
      priority: priority,
      faculty: faculty,
      tags: _makeTags(status: status, priority: priority, faculty: faculty),
      accent: _isUrgentPriority(priority) ? const Color(0xFF5B57D8) : null,
      actions: status == 'รออนุมัติ'
          ? const <String>['แก้ไข', 'อนุมัติ']
          : const <String>['แก้ไข', 'ลบ'],
    );
  }

  _Announcement copyWith({
    String? title,
    String? summary,
    String? body,
    String? author,
    String? updatedAt,
    String? expiresAt,
    String? status,
    String? priority,
    String? faculty,
    List<_Tag>? tags,
    List<String>? actions,
    Color? accent,
  }) {
    return _Announcement(
      title: title ?? this.title,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      author: author ?? this.author,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      faculty: faculty ?? this.faculty,
      tags: tags ?? this.tags,
      actions: actions ?? this.actions,
      accent: accent ?? this.accent,
    );
  }
}

class _Tag {
  const _Tag(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.time,
    this.highlighted = false,
  });

  final String title;
  final String time;
  final bool highlighted;
}
