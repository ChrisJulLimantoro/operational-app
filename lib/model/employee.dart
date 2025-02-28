class Employee {
  final String id;
  final String name;
  final String email;

  Employee({required this.id, required this.name, required this.email});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(id: json['id'], name: json['name'], email: json['email']);
  }
}
