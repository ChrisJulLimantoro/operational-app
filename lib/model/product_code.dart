import 'package:operational_app/model/product.dart';

class ProductCode {
  final String id;
  final String barcode;
  final double weight;
  final double fixedPrice;
  final double buyPrice;
  final double taxPurchase;
  final int status;
  final String? image;
  final DateTime? takenOutAt;
  final DateTime? createdAt;
  final String accountId;
  final String productId;
  final Product? product;

  ProductCode({
    required this.id,
    required this.barcode,
    required this.weight,
    required this.fixedPrice,
    required this.buyPrice,
    required this.taxPurchase,
    required this.status,
    required this.productId,
    required this.image,
    required this.takenOutAt,
    required this.createdAt,
    required this.accountId,
    this.product,
  });

  factory ProductCode.fromJSON(Map<String, dynamic> json) {
    return ProductCode(
      id: json['id'],
      barcode: json['barcode'],
      weight: double.tryParse(json['weight'] ?? '0.0') ?? 0.0,
      fixedPrice: double.tryParse(json['fixed_price'] ?? '0.0') ?? 0.0,
      buyPrice:
          json['buy_price'] != null
              ? double.tryParse(json['buy_price']) ?? 0.0
              : 0.0,
      taxPurchase:
          json['tax_purchase'] != null
              ? double.tryParse(json['tax_purchase']) ?? 0.0
              : 0.0,
      status: json['status'],
      productId: json['product_id'],
      image: json['image'],
      takenOutAt:
          json['taken_out_at'] != null
              ? DateTime.tryParse(json['taken_out_at'])
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      accountId: json['account_id'] ?? '',
      product:
          json['product'] != null ? Product.fromJSON(json['product']) : null,
    );
  }
}
