class Operation {
  final String id;
  final String code;
  final String name;
  final String? description;
  final double price;
  final String uom;
  final String storeId;
  final DateTime? createdAt;

  Operation({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.uom,
    required this.storeId,
    required this.createdAt,
  });

  factory Operation.fromJSON(Map<String, dynamic> json) {
    return Operation(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'] ?? "-",
      price: double.tryParse(json['price']) ?? 0.0,
      uom: json['uom'],
      storeId: json['store_id'],
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }
}
