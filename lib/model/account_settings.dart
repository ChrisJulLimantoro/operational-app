import 'package:flutter/material.dart';
import 'package:operational_app/model/maction.dart';
import 'package:operational_app/model/store.dart';

class AccountSetting {
  final int id;
  final String storeId;
  final String accountId;
  final String action;
  final Store store;
  final Maction maction;
  final DateTime? createdAt;

  AccountSetting({
    required this.id,
    required this.storeId,
    required this.accountId,
    required this.action,
    required this.store,
    required this.maction,
    this.createdAt,
  });

  factory AccountSetting.fromJSON(Map<String, dynamic> json) {
    debugPrint("AccountSetting JSON: $json");
    return AccountSetting(
      id: json['id'],
      storeId: json['store_id'] as String,
      accountId: json['account_id'] as String,
      action: json['action'] as String,
      store: Store.fromJSON(json['store']),
      maction: Maction.fromJSON(json['maction']),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}