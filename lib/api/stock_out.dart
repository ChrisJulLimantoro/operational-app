import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/stock_out.dart';
import 'package:operational_app/theme/colors.dart';

class StockOutAPI {
  // Fetching StockOut FROM API
  static Future<List<StockOut>> fetchStockOuts(
    BuildContext context, {
    int page = 0,
    int limit = 0,
    String search = '',
  }) async {
    try {
      final response = await ApiHelper.get(
        context,
        '/inventory/stock-out',
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
      return (response.data['data'] as List)
          .map((json) => StockOut.fromJSON(json))
          .toList();
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed:
            () => fetchStockOuts(
              context,
              page: page,
              limit: limit,
              search: search,
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
            () => fetchStockOuts(
              context,
              page: page,
              limit: limit,
              search: search,
            ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }

  static Future<bool> unstockOut(BuildContext context, String id) async {
    try {
      final response = await ApiHelper.delete(
        context,
        '/inventory/unstock-out/$id',
      );

      if (!response.data['success']) {
        throw Exception("Failed to unstock out");
      }
      if (!context.mounted) return true;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Berhasil mengembalikan barang",
        icon: Icons.check_circle_outline,
        primaryColor: AppColors.success,
        primaryButtonText: "OK",
        onPrimaryPressed: () => {},
      );
      return true;
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => unstockOut(context, id),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal melakukan unstock out",
        message: "$e",
        primaryButtonText: "OK",
        onPrimaryPressed: () => {},
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }

  static Future<bool> saveStockOut(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiHelper.post(
        context,
        '/inventory/stock-out',
        data: data,
      );

      if (!response.data['success']) {
        throw Exception("Failed to stock out");
      }
      debugPrint(response.toString());

      if (!context.mounted) return false;

      return true;
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal melakukan stock out",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "OK",
        onPrimaryPressed: () => {},
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal melakukan stock out",
        message: "$e",
        primaryButtonText: "OK",
        onPrimaryPressed: () => {},
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }
}
