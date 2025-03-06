import 'package:operational_app/model/product_code.dart';
// import 'package:operational_app/model/store.dart';
import 'package:operational_app/model/type.dart';

class Product {
  final String id;
  final String code;
  final String name;
  final String? description;
  final int status;
  final String typeId;
  final String storeId;
  final Type type;
  // final Store store;
  final List<ProductCode> productCodes;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.status,
    required this.typeId,
    required this.storeId,
    required this.type,
    // required this.store,
    required this.productCodes,
    required this.createdAt,
  });

  factory Product.fromJSON(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'] ?? "-",
      status: json['status'],
      typeId: json['type_id'],
      storeId: json['store_id'],
      type: Type.fromJSON(json['type']),
      // store: Store.fromJSON(json['store']),
      productCodes:
          (json['product_codes'] as List?)
              ?.map((e) => ProductCode.fromJSON(e))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }
}
