class Maction {
  final int id;
  final String action;
  final String description;
  final String name;
  final DateTime? createdAt;

  Maction({
    required this.id,
    required this.action,
    required this.description,
    required this.name,
    required this.createdAt,
  });

  factory Maction.fromJSON(Map<String, dynamic> json) {
    return Maction(
      id: json['id'],
      action: json['action'],
      description: json['description'] ?? "-",
      name: json['name'] ?? "-",
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }
}
