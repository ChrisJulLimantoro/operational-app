import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/stock_opname.dart';
import 'package:operational_app/theme/colors.dart';

class StockOpnameAPI {
  // Fetching StockOpname FROM API
  static Future<List<StockOpname>> fetchStockOpnames(
    BuildContext context,
    int page,
    int limit,
  ) async {
    try {
      final response = await ApiHelper.get(
        context,
        '/inventory/stock-opname',
        params: {'page': page, 'limit': limit},
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
          .map((json) => StockOpname.fromJSON(json))
          .toList();
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchStockOpnames(context, page, limit),
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
        onPrimaryPressed: () => fetchStockOpnames(context, page, limit),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }

  // Fetching StockOpname Details FROM API

  // Fetching Product Code FROM API
  static Future<List<Map<String, dynamic>>> fetchProductCode(
    BuildContext context,
    String categoryId,
  ) async {
    // Fetch product code
    try {
      final response = await ApiHelper.get(
        context,
        '/inventory/product-code',
        params: {'category_id': categoryId},
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
          .map(
            (json) => {
              'id': json['id'],
              'code': json['barcode'],
              'name': json['product']['name'],
              'type': json['product']['type']['name'],
              'weight': json['product']['weight'],
              'status': json['status'],
              'scanned': false,
            },
          )
          .toList();
    } on DioException catch (e) {
      debugPrint('$e');
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchProductCode(context, categoryId),
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
        onPrimaryPressed: () => fetchProductCode(context, categoryId),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }

  // Scanning Product to API
  static Future<bool> scanProduct(
    BuildContext context,
    String stockOpnameId,
    String code,
  ) async {
    try {
      final response = await ApiHelper.post(
        context,
        '/inventory/stock-opname-detail/$stockOpnameId',
        data: {'product_code': code, 'scanned': true},
      );

      if (!response.data['success']) {
        throw Exception("Failed to scan product");
      }

      if (!context.mounted) {
        return false;
      }

      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Barang berhasil discan",
        primaryButtonText: "OK",
        primaryColor: AppColors.success,
        icon: Icons.check_circle_outline,
        onPrimaryPressed: () {},
      );

      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        NotificationHelper.showSnackbar(
          message: "Connection timeout. Please try again.",
          backgroundColor: AppColors.error,
          actionLabel: "Retry",
          onActionPressed: () => scanProduct(context, stockOpnameId, code),
        );
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "${e.response?.data['message'] ?? "Gagal memindai barang"}",
          primaryButtonText: "Retry",
          onPrimaryPressed: () => scanProduct(context, stockOpnameId, code),
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
        );
      }
      return false;
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal",
        message: "$e",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => scanProduct(context, stockOpnameId, code),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }

  static Future<bool> approve(BuildContext context, String id) async {
    try {
      final response = await ApiHelper.put(
        context,
        '/inventory/stock-opname-approve/$id',
      );

      if (!response.data['success']) {
        throw Exception("Failed to approve stock opname");
      }

      if (!context.mounted) {
        return false;
      }

      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Stock Opname berhasil diapprove",
        primaryButtonText: "OK",
        primaryColor: AppColors.success,
        icon: Icons.check_circle_outline,
        onPrimaryPressed: () {},
      );

      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        NotificationHelper.showSnackbar(
          message: "Connection timeout. Please try again.",
          backgroundColor: AppColors.error,
          actionLabel: "Retry",
          onActionPressed: () => approve(context, id),
        );
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "${e.response?.data['message'] ?? "Gagal memindai barang"}",
          primaryButtonText: "Retry",
          onPrimaryPressed: () => approve(context, id),
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
        );
      }
      return false;
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal",
        message: "$e",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => approve(context, id),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }

  static Future<bool> disapprove(BuildContext context, String id) async {
    try {
      final response = await ApiHelper.put(
        context,
        '/inventory/stock-opname-disapprove/$id',
      );

      if (!response.data['success']) {
        throw Exception("Failed to approve stock opname");
      }

      if (!context.mounted) {
        return false;
      }

      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Berhasil",
        message: "Stock Opname berhasil ditolak",
        primaryButtonText: "OK",
        primaryColor: AppColors.success,
        icon: Icons.check_circle_outline,
        onPrimaryPressed: () {},
      );

      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        NotificationHelper.showSnackbar(
          message: "Connection timeout. Please try again.",
          backgroundColor: AppColors.error,
          actionLabel: "Retry",
          onActionPressed: () => approve(context, id),
        );
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal",
          message: "${e.response?.data['message'] ?? "Gagal memindai barang"}",
          primaryButtonText: "Retry",
          onPrimaryPressed: () => approve(context, id),
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
        );
      }
      return false;
    } on Exception catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal",
        message: "$e",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => approve(context, id),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }
}
