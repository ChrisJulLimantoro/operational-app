class TransactionOperation {
  final String id;
  final String transactionId;
  final String operationId;
  final String type;
  final String name;
  final double unit;
  final double price;
  final double adjustmentPrice;
  final double totalPrice;
  final String comment;

  TransactionOperation({
    required this.id,
    required this.transactionId,
    required this.operationId,
    required this.type,
    required this.name,
    required this.unit,
    required this.price,
    required this.adjustmentPrice,
    required this.totalPrice,
    required this.comment,
  });

  factory TransactionOperation.fromJSON(Map<String, dynamic> json) {
    return TransactionOperation(
      id: json['id'],
      transactionId: json['transaction_id'],
      operationId: json['operation_id'],
      type: json['type'],
      name: json['name'],
      unit: double.tryParse(json['unit']) ?? 0.0,
      price: double.tryParse(json['price']) ?? 0.0,
      adjustmentPrice: double.tryParse(json['adjustment_price']) ?? 0.0,
      totalPrice: double.tryParse(json['total_price']) ?? 0.0,
      comment: json['comment'] ?? '-',
    );
  }

  static Map<String, dynamic> toJSON(TransactionOperation to) {
    return {
      'id': to.id,
      'transaction_id': to.transactionId,
      'operation_id': to.operationId,
      'type': to.type,
      'name': to.name,
      'unit': to.unit,
      'quantity': to.unit,
      'price': to.price,
      'adjustment_price': to.adjustmentPrice,
      'total_price': to.totalPrice,
      'comment': to.comment,
      'detail_type': 'operation',
    };
  }
}
