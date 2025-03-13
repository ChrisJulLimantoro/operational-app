class StockOut {
  final String id;
  final String barcode;
  final String name;
  final double price;
  final double weight;
  final DateTime takenOutAt;
  final int takenOutReason;
  final String type;

  StockOut({
    required this.id,
    required this.barcode,
    required this.name,
    required this.price,
    required this.weight,
    required this.takenOutAt,
    this.takenOutReason = 0,
    required this.type,
  });

  factory StockOut.fromJSON(Map<String, dynamic> json) {
    print(json);
    return StockOut(
      id: json['id'],
      barcode: json['barcode'],
      name: json['name'],
      price: double.tryParse(json['price']) ?? 0.0,
      weight: double.tryParse(json['weight']) ?? 0.0,
      takenOutAt: DateTime.tryParse(json['taken_out_at']) ?? DateTime.now(),
      takenOutReason: json['taken_out_reason'],
      type: json['type'],
    );
  }
}
