import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/bank_account.dart'; // Sudah ada
import 'package:operational_app/model/payout_requests.dart'; // Baru
import 'package:operational_app/model/balance_logs.dart'; // Baru
import 'package:operational_app/theme/colors.dart';

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
      debugPrint('Error parsing double from string "$value": $e');
      return 0.0; // Default to 0.0 on parsing error
    }
  }
  debugPrint('Unexpected type for double parsing: ${value.runtimeType}');
  return 0.0; // Default for unexpected types
}

// Model untuk menampung seluruh data Store Balance
class StoreBalanceData {
  final double balance;
  final List<PayoutRequest> payoutRequests;
  final List<BalanceLog> balanceLogs;
  final List<BankAccount> bankAccounts;

  StoreBalanceData({
    required this.balance,
    required this.payoutRequests,
    required this.balanceLogs,
    required this.bankAccounts,
  });

  factory StoreBalanceData.fromJSON(Map<String, dynamic> json) {
    return StoreBalanceData(
      balance:
          _parseDoubleSafely(json['balance']), // FIX: Use helper for balance
      payoutRequests: (json['PayoutRequest'] as List)
          .map((item) => PayoutRequest.fromJSON(item as Map<String, dynamic>))
          .toList(),
      balanceLogs: (json['BalanceLog'] as List)
          .map((item) => BalanceLog.fromJSON(item as Map<String, dynamic>))
          .toList(),
      bankAccounts: (json['BankAccount'] as List)
          .map((item) => BankAccount.fromJSON(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StoreBalanceAPI {
  static Future<StoreBalanceData?> fetchStoreBalanceData(
    BuildContext context,
  ) async {
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState.storeId.isEmpty) {
        debugPrint("Auth Store ID is empty, cannot fetch store balance data.");
        return null;
      }
      final storeId = authState.storeId;

      final response = await ApiHelper.get(
        context,
        '/transaction/store/$storeId',
      );
      print(response.data);

      if (!response.data['success']) {
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception(
            "Unexpected response format: Expected a Map, got ${response.data.runtimeType}");
      }

      // Asumsi data utama ada di response.data['data']
      return StoreBalanceData.fromJSON(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (!context.mounted) return null;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data Saldo Toko",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchStoreBalanceData(context),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }

  /// Fungsi untuk mengajukan Payout Request
  static Future<bool> submitPayoutRequest(
    BuildContext context, {
    required String bankAccountId,
    required double amount,
    required String reason,
  }) async {
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState.storeId.isEmpty) {
        debugPrint("Auth Store ID is empty, cannot submit payout request.");
        return false;
      }
      final storeId = authState.storeId;

      final response = await ApiHelper.post(
        context,
        '/transaction/payout_request', // Endpoint untuk submit payout request
        data: {
          'store_id': storeId,
          'bank_account_id': bankAccountId,
          'amount': amount,
          'reason': reason,
        },
      );

      if (!context.mounted) return false;

      if (response.data['success']) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Sukses!",
          message: "Permintaan Payout berhasil diajukan.",
          primaryButtonText: "OK",
          onPrimaryPressed: () => Navigator.pop(context), // Tutup notifikasi
          icon: Icons.check_circle_outline,
          primaryColor: AppColors.bluePrimary,
        );
        return true;
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal Mengajukan Payout",
          message: response.data['message'] ?? "Terjadi kesalahan.",
          primaryButtonText: "OK",
          onPrimaryPressed: () => Navigator.pop(context), // Tutup notifikasi
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
        );
        return false;
      }
    } on DioException catch (e) {
      if (!context.mounted) return false;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal Mengajukan Payout",
        message:
            "${e.response?.data['message'] ?? "Gagal mengajukan permintaan karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => submitPayoutRequest(
          context,
          bankAccountId: bankAccountId,
          amount: amount,
          reason: reason,
        ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }
}
