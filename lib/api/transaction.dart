import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/transaction.dart';
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

  static Future<Transaction?> fetchTransactionById(
    BuildContext context,
    String id,
  ) async {
    try {
      final uri = '/transaction/transaction/$id';
      final response = await ApiHelper.get(context, uri);
      if (!response.data['success']) {
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      debugPrint('Hello: ${response.data['data']}');
      return Transaction.fromJSON(response.data['data']);
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchTransactionById(context, id),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message: "$e",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchTransactionById(context, id),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
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
          (form['transaction_details'] as List)
              .where(
                (tp) =>
                    tp['transaction_type'] == 1 &&
                    tp['detail_type'] == 'product',
              )
              .length;
      final boughtCount =
          (form['transaction_details'] as List)
              .where(
                (tp) =>
                    tp['transaction_type'] == 2 &&
                    tp['detail_type'] == 'product',
              )
              .length;
      final operationCount =
          (form['transaction_details'] as List)
              .where((to) => to['detail_type'] == 'operation')
              .length;

      if (form['customer_id'] == null || form['customer_id'] == '') {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Silahkan pilih customer terlebih dahulu",
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
          primaryColor: AppColors.error,
        );
        return false;
      }

      // for Sales
      if (soldCount == 0 &&
          operationCount == 0 &&
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
          (boughtCount == 0 && (soldCount == 0 || operationCount == 0))) {
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

  static Future<bool> approveDisapprove(
    BuildContext context,
    int newstatus,
    transId,
  ) async {
    try {
      final response = await ApiHelper.put(
        context,
        newstatus == 1
            ? '/transaction/transaction-approve/$transId'
            : '/transaction/transaction-disapprove/$transId',
        data: {'approve': newstatus},
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

  static Future<bool> deleteTransaction(
    BuildContext context,
    String transId,
  ) async {
    try {
      final response = await ApiHelper.delete(
        context,
        '/transaction/transaction/$transId',
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
      debugPrint('Error deleting transaction: $e');
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengirim data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => deleteTransaction(context, transId),
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
        onPrimaryPressed: () => deleteTransaction(context, transId),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }

  // Create new Transaction Detail
  static Future<Map<String, dynamic>> createTransactionDetail(
    BuildContext context,
    Map<String, dynamic> detail,
  ) async {
    try {
      final response = await ApiHelper.post(
        context,
        '/transaction/transaction-detail',
        data: detail,
      );
      debugPrint(response.data.toString());
      if (!context.mounted) return {'success': false};
      if (!response.data['success']) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: response.data['message'],
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
          primaryColor: AppColors.error,
        );
        return {'success': false};
      }

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      debugPrint('Error creating transaction detail: $e');
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengirim data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => createTransactionDetail(context, detail),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return {'success': false};
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message: "$e",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => createTransactionDetail(context, detail),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return {'success': false};
    }
  }

  // Update Transaction Detail [only for adj and value]
  static Future<bool> updateTransactionDetail(context, id, data) async {
    try {
      final response = await ApiHelper.put(
        context,
        '/transaction/transaction-detail/$id',
        data: data,
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
      debugPrint('Error creating transaction detail: $e');
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengirim data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => deleteTransactionDetail(context, id),
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
        onPrimaryPressed: () => deleteTransactionDetail(context, id),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }

  // Delete Transaction Detail
  static Future<bool> deleteTransactionDetail(
    BuildContext context,
    String id,
  ) async {
    try {
      final response = await ApiHelper.delete(
        context,
        '/transaction/transaction-detail/$id',
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
      debugPrint('Error creating transaction detail: $e');
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengirim data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengirim data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => deleteTransactionDetail(context, id),
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
        onPrimaryPressed: () => deleteTransactionDetail(context, id),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }

  // Save Transaction Update
  static Future<bool> updateTransaction(context, id, form) async {
    try {
      form['date'] = form['date'].toString();

      // Check validation for detail
      final soldCount =
          (form['transaction_details'] as List)
              .where(
                (tp) =>
                    tp['transaction_type'] == 1 &&
                    tp['detail_type'] == 'product',
              )
              .length;
      final boughtCount =
          (form['transaction_details'] as List)
              .where(
                (tp) =>
                    tp['transaction_type'] == 2 &&
                    tp['detail_type'] == 'product',
              )
              .length;
      final operationCount =
          (form['transaction_details'] as List)
              .where((to) => to['detail_type'] == 'operation')
              .length;

      if (form['customer_id'] == null || form['customer_id'] == '') {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "Silahkan pilih customer terlebih dahulu",
          primaryButtonText: "OK",
          onPrimaryPressed: () {},
          primaryColor: AppColors.error,
        );
        return false;
      }

      // for Sales
      if (soldCount == 0 &&
          operationCount == 0 &&
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
          (boughtCount == 0 && (soldCount == 0 || operationCount == 0))) {
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

      final response = await ApiHelper.put(
        context,
        '/transaction/transaction/$id',
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
}
