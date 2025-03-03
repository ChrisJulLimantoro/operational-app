class Employee {
  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }
}
