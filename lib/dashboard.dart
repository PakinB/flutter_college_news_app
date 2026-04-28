import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = 'ทั้งหมด';
  String selectedFaculty = 'ทุกคณะ';

  final List<String> filters = <String>[
    'ทั้งหมด',
    'เผยแพร่แล้ว',
    'ฉบับร่าง',
    'รออนุมัติ',
    'ด่วน',
  ];

  final List<_MenuItem> menuItems = const <_MenuItem>[
    _MenuItem(Icons.dashboard_rounded, 'แดชบอร์ด', active: true),
    _MenuItem(Icons.article_outlined, 'ข่าวทั้งหมด', count: '24'),
    _MenuItem(Icons.access_time_rounded, 'รออนุมัติ', count: '5', countColor: Color(0xFFF3B7BC)),
    _MenuItem(Icons.calendar_today_outlined, 'ข่าวหมดอายุ'),
    _MenuItem(Icons.people_outline_rounded, 'จัดการผู้ใช้', section: 'จัดการระบบ'),
    _MenuItem(Icons.school_outlined, 'จัดการคณะ'),
  ];

  final List<_StatCardData> statCards = const <_StatCardData>[
    _StatCardData('ข่าวทั้งหมด', '124', 'เดือนนี้ +12', Color(0xFF232323)),
    _StatCardData('เผยแพร่แล้ว', '98', '79% ของทั้งหมด', Color(0xFF5E9734)),
    _StatCardData('รออนุมัติ', '5', 'ต้องดำเนินการ', Color(0xFFAF7320)),
    _StatCardData('ข่าวด่วน', '3', 'กำลังแสดงอยู่', Color(0xFFC74A47)),
  ];

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

  late final List<_Announcement> announcements = <_Announcement>[
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
      title: 'รับสมัครนักศึกษาเข้าร่วมโครงการแลกเปลี่ยนต่างประเทศ ประจำปีการศึกษา 2568',
      summary: 'เปิดรับสมัครนักศึกษาที่สนใจเข้าร่วมโครงการ',
      body: 'มหาวิทยาลัยเปิดรับสมัครนักศึกษาที่สนใจเข้าร่วมโครงการแลกเปลี่ยนกับมหาวิทยาลัยชั้นนำใน 12 ประเทศ',
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

  List<_Announcement> get filteredAnnouncements {
    if (selectedFilter == 'ทั้งหมด') {
      return announcements;
    }

    return announcements.where((_Announcement item) {
      if (selectedFilter == 'ด่วน') {
        return item.priority == 'ด่วน';
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
                          color: item.highlighted ? const Color(0xFF5B57D8) : const Color(0xFFC9C7C2),
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
    final _Announcement? updated = await _showAnnouncementEditor(existing: announcements[index]);
    if (updated == null) {
      return;
    }

    setState(() {
      announcements[index] = updated;
    });
  }

  Future<_Announcement?> _showAnnouncementEditor({_Announcement? existing}) async {
    final bool isEdit = existing != null;
    final TextEditingController titleController = TextEditingController(text: existing?.title ?? '');
    final TextEditingController summaryController = TextEditingController(text: existing?.summary ?? '');
    final TextEditingController bodyController = TextEditingController(text: existing?.body ?? '');

    String priority = existing?.priority ?? 'ปกติ';
    String faculty = existing?.faculty ?? 'ทั้งมหาวิทยาลัย';
    String publishDate = existing == null ? '04/28/2025' : '04/28/2025';
    String expireDate = existing == null ? '05/28/2025' : '05/28/2025';

    final _Announcement? result = await showDialog<_Announcement>(
      context: context,
      barrierColor: Colors.black45,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setDialogState) {
            return _DashboardDialog(
              title: isEdit ? 'แก้ไขข่าว' : 'สร้างข่าวใหม่',
              maxWidth: 680,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _DialogFieldLabel(isEdit ? 'หัวข้อข่าว *' : 'หัวข้อข่าว *'),
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
                          items: const <String>['ทั้งมหาวิทยาลัย', 'คณะวิศวกรรมศาสตร์', 'คณะบริหารธุรกิจ'],
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
                            onTap: () => setDialogState(() => publishDate = '04/28/2025'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _DialogDateField(
                            label: 'วันหมดอายุ',
                            value: expireDate,
                            onTap: () => setDialogState(() => expireDate = '05/28/2025'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _DialogFieldLabel('แนบไฟล์'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                          summary: summaryController.text.trim().isEmpty ? body : summaryController.text.trim(),
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
          : const _Tag('คณะวิศวกรรมศาสตร์', Color(0xFFBBD5F2), Color(0xFF295C94)),
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
                const TextSpan(text: ' ใช่หรือไม่?\n\nการลบข่าวจะไม่สามารถกู้คืนได้'),
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

        return Scaffold(
          drawer: isDesktop ? null : Drawer(child: SafeArea(child: _Sidebar(menuItems: menuItems))),
          body: SafeArea(
            child: Row(
              children: <Widget>[
                if (isDesktop)
                  SizedBox(
                    width: 264,
                    child: _Sidebar(menuItems: menuItems),
                  ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Color(0xFFE0D7C8))),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(isTablet ? 20 : 14, 16, isTablet ? 20 : 14, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _ResponsiveTopBar(
                            isDesktop: isDesktop,
                            onNotificationsTap: _showNotificationsDialog,
                            onCreateTap: _showCreateNewsDialog,
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
                            onFilterChanged: (String value) {
                              setState(() => selectedFilter = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: List<Widget>.generate(filteredAnnouncements.length, (int visibleIndex) {
                              final _Announcement item = filteredAnnouncements[visibleIndex];
                              final int actualIndex = announcements.indexOf(item);
                              return Padding(
                                padding: EdgeInsets.only(bottom: visibleIndex == filteredAnnouncements.length - 1 ? 0 : 12),
                                child: _AnnouncementCard(
                                  announcement: item,
                                  compact: !isTablet,
                                  onActionPressed: (String action) {
                                    if (action == 'แก้ไข') {
                                      _showEditNewsDialog(actualIndex);
                                    } else if (action == 'ลบ') {
                                      _showDeleteDialog(actualIndex);
                                    } else if (action == 'อนุมัติ') {
                                      _approveAnnouncement(actualIndex);
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                        ],
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
        final double availableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 420;
        final double searchWidth = isDesktop ? 360 : availableWidth.clamp(180.0, 420.0).toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                if (!isDesktop)
                  Builder(
                    builder: (BuildContext context) {
                      return _IconSurface(
                        size: 56,
                        child: IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: const Icon(Icons.menu_rounded),
                        ),
                      );
                    },
                  ),
                const SizedBox(
                  width: 72,
                  child: Text(
                    'แดช\nบอร์ด',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: searchWidth,
                  child: Container(
                    height: 46,
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
                            style: TextStyle(
                              color: Color(0xFF8A857A),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _IconSurface(
                  child: IconButton(
                    onPressed: onNotificationsTap,
                    icon: const Icon(Icons.notifications_none_rounded, size: 22),
                  ),
                  overlayDot: true,
                ),
                InkWell(
                  onTap: onCreateTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD8CEBC)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.add_rounded, size: 20),
                        SizedBox(width: 6),
                        Text(
                          '+ สร้าง\nข่าวใหม่',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const _IconSurface(
                  child: Icon(Icons.more_horiz_rounded),
                  fillColor: Colors.white,
                ),
              ],
            ),
          ],
        );
      },
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
            : (isTablet ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: statCards.map((_StatCardData item) {
            return SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
              color: selectedFilter == filter ? const Color(0xFF4B47C3) : const Color(0xFF59554B),
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
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF5E5A50),
          ),
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
                                children: announcement.tags.map((_Tag tag) => _TagPill(tag: tag)).toList(),
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
                                  children: announcement.tags.map((_Tag tag) => _TagPill(tag: tag)).toList(),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.menuItems});

  final List<_MenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    String? currentSection;

    return Container(
      color: const Color(0xFFF8F5EE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'UniAnnounce',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'ระบบประกาศข่าวมหาวิทยาลัย',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5E5A50),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE1D8C8)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Row(
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D2FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'AK',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4E49B7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'อรรถกร กิติ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Admin',
                        style: TextStyle(
                          color: Color(0xFF555147),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE1D8C8)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
              children: menuItems.map((_MenuItem item) {
                final List<Widget> sectionWidgets = <Widget>[];

                if (item.section != null && item.section != currentSection) {
                  currentSection = item.section;
                  sectionWidgets.add(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Text(
                        item.section!,
                        style: const TextStyle(
                          color: Color(0xFF726D62),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }

                sectionWidgets.add(
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: item.active ? const Color(0xFFE5E3FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        item.icon,
                        color: item.active ? const Color(0xFF4E49B7) : const Color(0xFF4D4940),
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: item.active ? FontWeight.w700 : FontWeight.w600,
                          color: item.active ? const Color(0xFF4E49B7) : const Color(0xFF4D4940),
                        ),
                      ),
                      trailing: item.count == null
                          ? null
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.countColor ?? const Color(0xFFD9D1FF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item.count!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF443F9D),
                                ),
                              ),
                            ),
                      onTap: () {},
                    ),
                  ),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sectionWidgets,
                );
              }).toList(),
            ),
          ),
        ],
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          value: value,
          onChanged: onChanged,
          items: items
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 15),
                  ),
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

class _MenuItem {
  const _MenuItem(
    this.icon,
    this.label, {
    this.active = false,
    this.count,
    this.countColor,
    this.section,
  });

  final IconData icon;
  final String label;
  final bool active;
  final String? count;
  final Color? countColor;
  final String? section;
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
