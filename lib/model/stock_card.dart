class StockCard {
  final String productId;
  final String? transCode;
  final DateTime date;
  final String code;
  final String name;
  final String description;
  final int inQty;
  final int outQty;
  final String balance;
  final String weightIn;
  final String weightOut;
  final String balanceWeight;
  final String avgPricePerWeight;

  StockCard({
    required this.productId,
    this.transCode,
    required this.date,
    required this.code,
    required this.name,
    required this.description,
    required this.inQty,
    required this.outQty,
    required this.balance,
    required this.weightIn,
    required this.weightOut,
    required this.balanceWeight,
    required this.avgPricePerWeight,
  });

  factory StockCard.fromJSON(Map<String, dynamic> json) {
    return StockCard(
      productId: json['product_id'] ?? '',
      transCode: json['trans_code'],
      date: DateTime.parse(json['date']),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      inQty: json['in'] ?? 0,
      outQty: json['out'] ?? 0,
      balance: json['balance'] ?? '0',
      weightIn: json['weight_in'] ?? '0',
      weightOut: json['weight_out'] ?? '0',
      balanceWeight: json['balance_weight'] ?? '0',
      avgPricePerWeight: json['avg_price_per_weight'] ?? '0',
    );
  }
}