import 'package:flutter/material.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.author,
    required this.status,
    required this.priority,
    required this.targetType,
    this.targetFacultyId,
    required this.targetFacultyName,
    required this.createdAt,
    required this.updatedAt,
    required this.expiredAt,
  });

  final int id;
  final String title;
  final String summary;
  final String content;
  final String author;
  final String status;
  final String priority;
  final String targetType;
  final int? targetFacultyId;
  final String targetFacultyName;
  final String createdAt;
  final String updatedAt;
  final String expiredAt;

  bool get isPublished => status == 'published' || status == 'publish';
  bool get isPending => status == 'pending' || status == 'waiting';
  bool get isDraft => status == 'draft';
  bool get isUrgent => priority == 'urgent' || priority == 'high';
  bool get isAllFaculty => targetType == 'all' || targetFacultyId == null;
  bool get isExpired {
    if (expiredAt.isEmpty || expiredAt == '-') return false;
    final DateTime? date = DateTime.tryParse(expiredAt);
    if (date == null) return true;
    return date.isBefore(DateTime.now());
  }

  String get statusLabel {
    switch (status) {
      case 'published':
      case 'publish':
        return 'เผยแพร่แล้ว';
      case 'pending':
      case 'waiting':
        return 'รออนุมัติ';
      case 'draft':
        return 'ฉบับร่าง';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  String get priorityLabel => isUrgent ? 'ด่วน' : 'ปกติ';
  String get targetLabel => isAllFaculty ? 'ทุกคณะ' : targetFacultyName;
  Color? get accent => isUrgent ? const Color(0xFF5B57D8) : null;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    final String targetType = _text(json['target_type'], fallback: 'all');
    final int? targetFacultyId = int.tryParse('${json['target_faculty_id'] ?? ''}');
    return Announcement(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      title: _text(json['title']),
      summary: _text(json['summary'], fallback: ''),
      content: _text(json['content'] ?? json['body'] ?? json['summary']),
      author: _text(json['creator_name'] ?? json['created_by']),
      status: _text(json['status'], fallback: 'draft').toLowerCase(),
      priority: _text(json['priority'], fallback: 'normal').toLowerCase(),
      targetType: targetType,
      targetFacultyId: targetFacultyId,
      targetFacultyName: _text(
        json['target_faculty_name'] ?? json['faculty'],
        fallback: targetType == 'all' ? 'ทุกคณะ' : '-',
      ),
      createdAt: _text(json['created_at']),
      updatedAt: _text(json['updated_at'] ?? json['created_at']),
      expiredAt: _text(json['expired_at']),
    );
  }

  Map<String, dynamic> toPayload({required int createdBy}) {
    return <String, dynamic>{
      'title': title,
      'summary': summary,
      'content': content,
      'created_by': createdBy,
      'status': status,
      'priority': priority,
      'target_type': targetType,
      'target_faculty_id': targetFacultyId,
      'expired_at': expiredAt == '-' ? null : expiredAt,
      'published_at': status == 'published' ? DateTime.now().toIso8601String() : null,
    };
  }

  Announcement copyWith({
    int? id,
    String? title,
    String? summary,
    String? content,
    String? author,
    String? status,
    String? priority,
    String? targetType,
    int? targetFacultyId,
    String? targetFacultyName,
    String? createdAt,
    String? updatedAt,
    String? expiredAt,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      author: author ?? this.author,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      targetType: targetType ?? this.targetType,
      targetFacultyId: targetFacultyId ?? this.targetFacultyId,
      targetFacultyName: targetFacultyName ?? this.targetFacultyName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiredAt: expiredAt ?? this.expiredAt,
    );
  }
}

String _text(dynamic value, {String fallback = '-'}) {
  if (value == null) return fallback;
  final String text = '$value'.trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
  return text;
}
