class Voucher {
  final String id;
  final String code;
  final String name;
  final double discountAmount;
  final int poinPrice;
  final String? description;
  final bool isActive;
  final double maxDiscount;
  final double minPurchase;
  final DateTime startDate;
  final DateTime endDate;
  final String storeId;

  Voucher({
    required this.id,
    required this.code,
    required this.name,
    required this.discountAmount,
    required this.poinPrice,
    this.description,
    required this.isActive,
    required this.maxDiscount,
    required this.minPurchase,
    required this.startDate,
    required this.endDate,
    required this.storeId,
  });

  factory Voucher.fromJSON(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      discountAmount: _parseDoubleSafely(json['discount_amount']),
      poinPrice: json['poin_price'] as int,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      maxDiscount: _parseDoubleSafely(json['max_discount']),
      minPurchase: _parseDoubleSafely(json['min_purchase']),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      storeId: json['store_id'] as String,
    );
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value == null) {
      return 0.0;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'discount_amount': discountAmount,
      'poin_price': poinPrice,
      'description': description,
      'is_active': isActive,
      'max_discount': maxDiscount,
      'min_purchase': minPurchase,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'store_id': storeId,
    };
  }
}
