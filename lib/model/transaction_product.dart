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
  });

  factory TransactionProduct.fromJson(Map<String, dynamic> json) {
    return TransactionProduct(
      id: json['id'],
      transactionId: json['transaction_id'],
      productCodeId: json['product_code_id'],
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
    );
  }
}
