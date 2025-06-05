import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/voucher.dart';
import 'package:operational_app/theme/colors.dart';

class VoucherAPI {
  static Future<List<Voucher>> fetchVouchers(
    BuildContext context, {
    String search = '',
  }) async {
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState.storeId.isEmpty) {
        debugPrint("Auth Store ID is empty, cannot fetch vouchers.");
        return [];
      }
      final storeId = authState.storeId;

      final response = await ApiHelper.get(
        context,
        '/transaction/voucher/${storeId}/store',
        params: {'search': search},
      );

      if (!response.data['success']) {
        return [];
      }
      if (!context.mounted) {
        return [];
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception(
            "Unexpected response format: Expected a Map, got ${response.data.runtimeType}");
      }

      final result = (response.data['data'] as List)
          .map((json) => Voucher.fromJSON(json as Map<String, dynamic>))
          .toList();

      debugPrint('Fetched ${result.length} vouchers for store $storeId');
      return result;
    } on DioException catch (e) {
      if (!context.mounted) return [];
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data Voucher",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchVouchers(
          context,
          search: search,
        ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }
}
