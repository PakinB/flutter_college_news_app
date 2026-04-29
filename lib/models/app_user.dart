class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.facultyId,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final int? facultyId;

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isPr => role.toLowerCase() == 'pr';
  bool get isTeacher => role.toLowerCase() == 'teacher';
  bool get isStudent => role.toLowerCase() == 'student' || role.toLowerCase() == 'user';
  bool get canCreateNews => isAdmin || isPr || isTeacher;
  bool get canManageSystem => isAdmin;

  String get displayRole {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'แอดมิน';
      case 'pr':
        return 'ผู้ประกาศข่าว';
      case 'teacher':
        return 'อาจารย์';
      case 'student':
      case 'user':
        return 'นักศึกษา';
      default:
        return role.isEmpty ? '-' : role;
    }
  }

  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length < 2 ? parts.first.length : 2).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: '${json['name'] ?? '-'}',
      email: '${json['email'] ?? '-'}',
      role: _normalizeRole(json['role']),
      facultyId: int.tryParse('${json['faculty_id'] ?? ''}'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'faculty_id': facultyId,
    };
  }
}

String _normalizeRole(dynamic value) {
  final String role = '${value ?? 'student'}'.trim().toLowerCase();
  return role == 'user' ? 'student' : role;
}
