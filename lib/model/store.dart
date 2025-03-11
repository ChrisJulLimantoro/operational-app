import 'package:operational_app/model/company.dart';

class Store {
  final String id;
  final String code;
  final String name;
  final String npwp;
  final String address;
  final DateTime openDate;
  final double longitude;
  final double latitude;
  final String description;
  final bool isActive;
  final bool isFlexPrice;
  final bool isFloatPrice;
  final double taxPercentage;
  final int poinConfig;
  final String logo;
  final Company? company;
  final DateTime? createdAt;

  Store({
    required this.id,
    required this.code,
    required this.name,
    required this.npwp,
    required this.address,
    required this.openDate,
    required this.longitude,
    required this.latitude,
    required this.description,
    required this.isActive,
    required this.isFlexPrice,
    required this.isFloatPrice,
    required this.taxPercentage,
    required this.poinConfig,
    required this.logo,
    required this.company,
    required this.createdAt,
  });

  factory Store.fromJSON(Map<String, dynamic> json) {
    print(json);
    return Store(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      npwp: json['npwp'] ?? '-',
      address: json['address'] ?? '-',
      openDate:
          json['open_date'] != null
              ? DateTime.parse(json['open_date'].toString())
              : DateTime.now(),
      longitude:
          json['longitude'] != null
              ? double.tryParse(json['longitude'].toString()) ?? 0.0
              : 0.0,
      latitude:
          json['latitude'] != null
              ? double.tryParse(json['latitude'].toString()) ?? 0.0
              : 0.0,
      description: json['description'] ?? '-',
      isActive: json['is_active'] ?? false,
      isFlexPrice: json['is_flex_price'] ?? false,
      isFloatPrice: json['is_float_price'] ?? false,
      taxPercentage:
          json['tax_percentage'] != null
              ? double.tryParse(json['tax_percentage'].toString()) ?? 0.0
              : 0.0,
      poinConfig: json['poin_config'] ?? 0,
      logo: json['logo'] ?? '-',
      company:
          json['company'] != null ? Company.fromJSON(json['company']) : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }
}
