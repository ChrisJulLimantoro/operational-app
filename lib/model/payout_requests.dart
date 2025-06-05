import 'package:intl/intl.dart'; // Untuk format tanggal

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

class PayoutRequest {
  final String id;
  final String storeId;
  final String bankAccountId;
  final double amount;
  final String? reason;
  final int status; // 0 for pending, 1 for approved
  final String? proof; // URL or path to proof image
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  PayoutRequest({
    required this.id,
    required this.storeId,
    required this.bankAccountId,
    required this.amount,
    this.reason,
    required this.status,
    this.proof,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory PayoutRequest.fromJSON(Map<String, dynamic> json) {
    return PayoutRequest(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      bankAccountId: json['bank_account_id'] as String,
      amount: _parseDoubleSafely(json['amount']), // FIX: Use helper for amount
      reason: json['reason'] as String?,
      status: json['status'] as int,
      proof: json['proof'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'store_id': storeId,
      'bank_account_id': bankAccountId,
      'amount': amount,
      'reason': reason,
      'status': status,
      'proof': proof,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  String get formattedStatus {
    return status == 1 ? '✅ Approved' : '⏳ Pending';
  }

  String get formattedAmount {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String get formattedCreatedAt {
    return DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
  }
}
