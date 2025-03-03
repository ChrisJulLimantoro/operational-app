class Type {
  final String id;
  final String code;
  final String name;
  final String categoryId;
  final String description;
  final DateTime? createdAt;

  Type({
    required this.id,
    required this.code,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.createdAt,
  });

  factory Type.fromJSON(Map<String, dynamic> json) {
    return Type(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      categoryId: json['category_id'],
      description: json['description'],
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }
}
