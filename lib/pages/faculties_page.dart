import 'package:flutter/material.dart';

import '../models/faculty.dart';
import '../widgets/dashboard_widgets.dart';

class FacultiesPage extends StatelessWidget {
  const FacultiesPage({
    super.key,
    required this.faculties,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onSave,
  });

  final List<Faculty> faculties;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<void> Function(int id, Map<String, dynamic> payload) onSave;

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
            const Text('จัดการคณะ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (faculties.isEmpty)
              const EmptyState(message: 'ยังไม่มีคณะในฐานข้อมูล')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faculties.length,
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final Faculty faculty = faculties[index];
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
                              Text(faculty.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 8),
                              Text('รายละเอียด: ${faculty.description.isEmpty ? '-' : faculty.description}'),
                              const SizedBox(height: 4),
                              Text('สร้างเมื่อ: ${faculty.createdAt}'),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'แก้ไข',
                          onPressed: () => _showFacultyDialog(context, faculty),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFacultyDialog(BuildContext context, Faculty faculty) async {
    final TextEditingController name = TextEditingController(text: faculty.name);
    final TextEditingController description = TextEditingController(text: faculty.description);

    final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return DashboardDialog(
          title: 'แก้ไขคณะ',
          body: Column(
            children: <Widget>[
              TextField(controller: name, decoration: const InputDecoration(labelText: 'ชื่อคณะ')),
              const SizedBox(height: 14),
              TextField(
                controller: description,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'รายละเอียด'),
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
                  'name': name.text.trim(),
                  'description': description.text.trim(),
                }),
                child: const Text('บันทึก'),
              ),
            ],
          ),
        );
      },
    );

    name.dispose();
    description.dispose();
    if (result != null) await onSave(faculty.id, result);
  }
}
