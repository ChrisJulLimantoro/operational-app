import 'package:operational_app/model/company.dart';
import 'package:operational_app/model/type.dart';

enum MetalType {
  gold(1, 'Emas'),
  silver(2, 'Perak'),
  redGold(3, 'Emas Merah'),
  whiteGold(4, 'Emas Putih'),
  platinum(5, 'Platinum'),
  other(6, 'Lainnya');

  final int value;
  final String name;
  const MetalType(this.value, this.name);

  static MetalType fromInt(int value) {
    return MetalType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MetalType.other,
    );
  }
}

class Category {
  final String id;
  final String code;
  final String name;
  final String purity;
  final MetalType metalType;
  final double weightTray;
  final double weightPaper;
  final List<Type>? types;
  final String? description;
  final Company? company;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.code,
    required this.name,
    required this.purity,
    required this.metalType,
    required this.weightTray,
    required this.weightPaper,
    this.types,
    this.company,
    this.description,
    required this.createdAt,
  });

  factory Category.fromJSON(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      purity: json['purity'],
      metalType: MetalType.fromInt(json['metal_type']),
      weightTray: double.parse(json['weight_tray']),
      weightPaper: double.parse(json['weight_paper']),
      types:
          json['types'] != null
              ? (json['types'] as List).map((e) => Type.fromJSON(e)).toList()
              : null,
      description: json['description'] ?? '-',
      company:
          json['company'] != null ? Company.fromJSON(json['company']) : null,
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }
}
