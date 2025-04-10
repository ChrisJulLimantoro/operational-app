class TransactionProduct {
  final String id;
  final String transactionId;
  final String productCodeId;
  final int transactionType;
  final String name;
  final String type;
  final double weight;
  final double price;
  final double discount;
  final double adjustmentPrice;
  final double totalPrice;
  final int status;
  final String comment;
  final bool isBroken;

  TransactionProduct({
    required this.id,
    required this.transactionId,
    required this.productCodeId,
    required this.transactionType,
    required this.name,
    required this.type,
    required this.weight,
    required this.price,
    required this.discount,
    required this.adjustmentPrice,
    required this.totalPrice,
    required this.status,
    this.comment = '',
    this.isBroken = false,
  });

  factory TransactionProduct.fromJSON(Map<String, dynamic> json) {
    return TransactionProduct(
      id: json['id'],
      transactionId: json['transaction_id'],
      productCodeId: json['product_code_id'] ?? '',
      transactionType: json['transaction_type'],
      type: json['type'],
      name: json['name'],
      weight: double.tryParse(json['weight']) ?? 0.0,
      price: double.tryParse(json['price']) ?? 0.0,
      discount: double.tryParse(json['discount']) ?? 0.0,
      adjustmentPrice: double.tryParse(json['adjustment_price']) ?? 0.0,
      totalPrice: double.tryParse(json['total_price']) ?? 0.0,
      status: json['status'],
      comment: json['comment'] ?? '-',
      isBroken: json['is_broken'] ?? false,
    );
  }
  static Map<String, dynamic> toJSON(TransactionProduct tp) {
    return {
      'id': tp.id,
      'transaction_id': tp.transactionId,
      'product_code_id': tp.productCodeId != '' ? tp.productCodeId : null,
      'transaction_type': tp.transactionType,
      'name': tp.name,
      'type': tp.type,
      'weight': tp.weight,
      'quantity': tp.weight,
      'price': tp.price,
      'discount': tp.discount,
      'adjustment_price': tp.adjustmentPrice,
      'total_price': tp.totalPrice,
      'status': tp.status,
      'comment': tp.comment,
      'detail_type': 'product',
      'is_broken': tp.isBroken,
    };
  }
}
