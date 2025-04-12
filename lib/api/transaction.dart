import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/transaction.dart';
import 'package:operational_app/model/transaction_product.dart';
import 'package:operational_app/theme/colors.dart';

class TransactionAPI {
  // Fetching Transaction FROM API
  static Future<List<Transaction>> fetchTransactionsFromAPI(
    BuildContext context,
    int type, {
    int page = 0,
    int limit = 0,
    String search = '',
  }) async {
    try {
      final uri =
          type == 1
              ? '/transaction/sales'
              : type == 2
              ? '/transaction/purchase'
              : '/transaction/trade';
      final response = await ApiHelper.get(
        context,
        uri,
        params: {'page': page, 'limit': limit, 'search': search},
      );
      if (!response.data['success']) {
        return [];
      }
      if (!context.mounted) {
        return [];
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      return (response.data['data']['data'] as List)
          .map((json) => Transaction.fromJSON(json))
          .toList();
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed:
            () => fetchTransactionsFromAPI(
              context,
              type,
              page: page,
              limit: limit,
            ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message: "$e",
        primaryButtonText: "Retry",
        onPrimaryPressed:
            () => fetchTransactionsFromAPI(
              context,
              type,
              page: page,
              limit: limit,
            ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }

  static Future<bool> submitTransaction(
    BuildContext context,
    Map<String, dynamic> form,
  ) async {
    try {
      final authCubit = context.read<AuthCubit>();
      form['employee_id'] = authCubit.state.userId;
      form['store_id'] = authCubit.state.storeId;
      form['date'] = form['date'].toString();

      // Check validation for detail
      final soldCount =
          (form['transaction_products'] as List<TransactionProduct>)
              .where((tp) => tp.transactionType == 1)
              .length;
      final boughtCount =
          (form['transaction_products'] as List<TransactionProduct>)
              .where((tp) => tp.transactionType == 2)
              .length;
      // for Sales
      if (soldCount == 0 &&
          form['transaction_operations'].isEmpty() &&
          form['transaction_type'] == 1) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Silahkan pilih produk atau jasa untuk dijual",
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
          primaryColor: AppColors.error,
        );
        return false;
      }
      // for Purchase
      if (boughtCount == 0 && form['transaction_type'] == 2) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Silahkan pilih produk untuk dijual",
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
          primaryColor: AppColors.error,
        );
        return false;
      }
      // for Trade
      if (form['transaction_type'] == 3 &&
          (boughtCount == 0 &&
              (soldCount == 0 || form['transaction_operations'].isEmpty()))) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message:
              boughtCount == 0
                  ? "Silahkan pilih produk untuk dibeli dari customer"
                  : "Silahkan pilih produk atau jasa untuk dijual",
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
          primaryColor: AppColors.error,
        );
        return false;
      }

      final response = await ApiHelper.post(
        context,
        '/transaction/transaction',
        data: form,
      );
      debugPrint(response.data.toString());
      if (!context.mounted) return false;
      if (!response.data['success']) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: response.data['message'],
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
          primaryColor: AppColors.error,
        );
        return false;
      }

      return true;
    } on DioException catch (e) {
      debugPrint('Error submitting transaction: $e');
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengirim data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => submitTransaction(context, form),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message: "$e",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => submitTransaction(context, form),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }

  static Future<Map<String, dynamic>> fetchConfig(BuildContext context) async {
    final authCubit = context.read<AuthCubit>();
    final storeId = authCubit.state.storeId;
    try {
      final response = await ApiHelper.get(context, '/master/store/$storeId');
      if (!response.data['success']) {
        return {};
      }
      if (!context.mounted) {
        return {};
      }
      return response.data['data'];
    } on DioException catch (e) {
      debugPrint('Error submitting transaction: $e');
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengirim data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchConfig(context),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message: "$e",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchConfig(context),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
    }
    return {};
  }

  static Future<bool> approveDisapprove(BuildContext context, int newstatus, transId) async {
    try {
      final response = await ApiHelper.put(
        context,
        newstatus == 1
            ? '/transaction/transaction-approve/$transId'
            : '/transaction/transaction-disapprove/$transId',
        data: {
          'approve': newstatus,
        },
      );
      debugPrint(response.data.toString());
      if (!context.mounted) return false;
      if (!response.data['success']) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: response.data['message'],
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
          primaryColor: AppColors.error,
        );
        return false;
      }

      return true;
    } on DioException catch (e) {
      debugPrint('Error approving transaction: $e');
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengirim data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => approveDisapprove(context, newstatus, transId),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message: "$e",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => approveDisapprove(context, newstatus, transId),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }
}
