import 'package:intl/intl.dart';

double _parseDoubleSafely(dynamic value) {
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

class BalanceLog {
  final String id;
  final String storeId;
  final double amount;
  final String type; // e.g., "INCOME", "PAYOUT_REQUEST"
  final String information;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BalanceLog({
    required this.id,
    required this.storeId,
    required this.amount,
    required this.type,
    required this.information,
    required this.createdAt,
    this.updatedAt,
  });

  factory BalanceLog.fromJSON(Map<String, dynamic> json) {
    return BalanceLog(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      amount: _parseDoubleSafely(json['amount']), // FIX: Use helper for amount
      type: json['type'] as String,
      information: json['information'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'store_id': storeId,
      'amount': amount,
      'type': type,
      'information': information,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get formattedAmount {
    final formatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount.abs()); // Use abs() for formatting, then apply color
    return amount < 0 ? '- $formatted' : '+ $formatted';
  }

  String get formattedCreatedAt {
    return DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
  }
}
