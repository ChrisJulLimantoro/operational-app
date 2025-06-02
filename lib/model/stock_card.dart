import 'package:flutter/cupertino.dart';

class StockCard {
  final String productId;
  final String? transCode;
  final DateTime date;
  final String code;
  final String name;
  final String description;
  final double inQty;
  final double outQty;
  final String balance;
  final String weightIn;
  final String weightOut;
  final String balanceWeight;
  final String avgPricePerWeight;
  final double? price;

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
    this.price,
  });

  factory StockCard.fromJSON(Map<String, dynamic> json) {
    debugPrint("StockCard.fromJSON: $json");
    return StockCard(
      productId: json['product_id'] ?? '',
      transCode: json['trans_code'],
      date: DateTime.parse(json['date']).toLocal(),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      inQty: double.tryParse(json['in'].toString()) ?? 0.0,
      outQty: double.tryParse(json['out'].toString()) ?? 0.0,
      balance: (double.tryParse(json['balance'].toString()) ?? 0.0).toString(),
      weightIn: (double.tryParse(json['weight_in'].toString()) ?? 0.0).toString(),
      weightOut: (double.tryParse(json['weight_out'].toString()) ?? 0.0).toString(),
      balanceWeight: (double.tryParse(json['balance_weight'].toString()) ?? 0.0).toString(),
      avgPricePerWeight: json['unit_price'] ?? '0',
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
    );
  }

}