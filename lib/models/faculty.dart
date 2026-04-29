class Faculty {
  const Faculty({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String description;
  final String createdAt;

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: '${json['name'] ?? '-'}',
      description: '${json['description'] ?? ''}',
      createdAt: '${json['created_at'] ?? '-'}',
    );
  }
}
