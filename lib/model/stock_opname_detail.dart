import 'package:operational_app/model/product_code.dart';

class StockOpnameDetail {
  final String id;
  final String stockOpnameId;
  final String productCodeId;
  final ProductCode? productCode;
  final String? description;
  final bool scanned;
  final DateTime? createdAt;

  StockOpnameDetail({
    required this.id,
    required this.stockOpnameId,
    required this.productCodeId,
    this.productCode,
    this.description,
    this.scanned = false,
    required this.createdAt,
  });

  factory StockOpnameDetail.fromJSON(Map<String, dynamic> json) {
    return StockOpnameDetail(
      id: json['id'],
      stockOpnameId: json['stock_opname_id'],
      productCodeId: json['product_code_id'],
      productCode:
          json['productCode'] != null
              ? ProductCode.fromJSON(json['productCode'])
              : null,
      description: json['description'] ?? '-',
      scanned: json['scanned'] ?? false,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
    );
  }
}
