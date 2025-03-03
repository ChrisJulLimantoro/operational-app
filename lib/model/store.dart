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
  final Company company;
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
    return Store(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      npwp: json['npwp'],
      address: json['address'],
      openDate: DateTime.parse(json['open_date']),
      longitude: double.parse(json['longitude']),
      latitude: double.parse(json['latitude']),
      description: json['description'] ?? '-',
      isActive: json['is_active'],
      isFlexPrice: json['is_flex_price'],
      isFloatPrice: json['is_float_price'],
      taxPercentage: double.parse(json['tax_percentage']),
      poinConfig: json['poin_config'],
      logo: json['logo'],
      company: Company.fromJSON(json['company']),
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }
}
