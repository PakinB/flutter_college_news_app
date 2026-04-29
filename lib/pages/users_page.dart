import 'package:flutter/material.dart';

import '../models/faculty.dart';
import '../widgets/dashboard_widgets.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({
    super.key,
    required this.users,
    required this.faculties,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onSave,
  });

  final List<Map<String, dynamic>> users;
  final List<Faculty> faculties;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Map<String, dynamic> payload) onSave;

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
            const Text('จัดการผู้ใช้', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (users.isEmpty)
              const EmptyState(message: 'ยังไม่มีผู้ใช้ในฐานข้อมูล')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> user = users[index];
                  final int? facultyId = int.tryParse('${user['faculty_id'] ?? ''}');
                  final Faculty? faculty = _facultyById(facultyId);
                  final String facultyName = faculty?.name ?? (facultyId == null ? '-' : 'ไม่พบคณะ');
                  final String facultyDescription = faculty?.description.trim().isEmpty ?? true
                      ? '-'
                      : faculty!.description;
                  return _DataCard(
                    title: '${user['name'] ?? '-'}',
                    lines: <String>[
                      'อีเมล: ${user['email'] ?? '-'}',
                      'สถานะ: ${_roleLabel(user['role'])}',
                      'คณะ: $facultyName',
                      'รายละเอียดคณะ: $facultyDescription',
                      'คณะ ID: ${facultyId ?? '-'}',
                    ],
                    onEdit: () => _showUserDialog(context, user),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Faculty? _facultyById(int? facultyId) {
    if (facultyId == null) return null;
    for (final Faculty faculty in faculties) {
      if (faculty.id == facultyId) return faculty;
    }
    return null;
  }

  Future<void> _showUserDialog(BuildContext context, Map<String, dynamic> user) async {
    final TextEditingController name = TextEditingController(text: '${user['name'] ?? ''}');
    final TextEditingController password = TextEditingController();
    int? facultyId = int.tryParse('${user['faculty_id'] ?? ''}');
    String role = _normalizeRole(user['role']);

    final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setDialogState) {
            return DashboardDialog(
              title: 'แก้ไขผู้ใช้',
              body: Column(
                children: <Widget>[
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'ชื่อ')),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: facultyId,
                    decoration: const InputDecoration(labelText: 'คณะ'),
                    items: faculties
                        .map((Faculty item) => DropdownMenuItem<int>(value: item.id, child: Text(item.name)))
                        .toList(),
                    onChanged: (int? value) => setDialogState(() => facultyId = value),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'บทบาท'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'admin', child: Text('แอดมิน')),
                      DropdownMenuItem(value: 'pr', child: Text('ผู้ประกาศข่าว')),
                      DropdownMenuItem(value: 'teacher', child: Text('อาจารย์')),
                      DropdownMenuItem(value: 'student', child: Text('นักศึกษา')),
                    ],
                    onChanged: (String? value) => setDialogState(() => role = value ?? role),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่ (ไม่กรอก = ไม่เปลี่ยน)'),
                  ),
                ],
              ),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('ยกเลิก')),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(<String, dynamic>{
                      'id': user['id'],
                      'name': name.text.trim(),
                      'faculty_id': facultyId,
                      'role': role,
                      if (password.text.isNotEmpty) 'password': password.text,
                    }),
                    child: const Text('บันทึก'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    name.dispose();
    password.dispose();
    if (result != null) await onSave(result);
  }
}

String _normalizeRole(dynamic value) {
  final String role = '${value ?? 'student'}'.trim().toLowerCase();
  return role == 'user' ? 'student' : role;
}

String _roleLabel(dynamic value) {
  switch (_normalizeRole(value)) {
    case 'admin':
      return 'แอดมิน';
    case 'pr':
      return 'ผู้ประกาศข่าว';
    case 'teacher':
      return 'อาจารย์';
    case 'student':
      return 'นักศึกษา';
    default:
      return '-';
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({required this.title, required this.lines, required this.onEdit});

  final String title;
  final List<String> lines;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDBD0BF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ...lines.map((String line) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(line, style: const TextStyle(color: Color(0xFF676257))),
                    )),
              ],
            ),
          ),
          IconButton(tooltip: 'แก้ไข', onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
    );
  }
}
