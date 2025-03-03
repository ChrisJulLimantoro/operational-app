class Company {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String ownerId;
  final DateTime? createdAt;

  Company({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
  });

  factory Company.fromJSON(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'] ?? '-',
      ownerId: json['owner_id'],
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }
}
