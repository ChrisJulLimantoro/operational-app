import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/product.dart';
import 'package:operational_app/theme/colors.dart';

class ProductAPI {
  static Future<List<Product>> fetchProducts(
    BuildContext context, {
    int page = 0,
    int limit = 0,
    String search = '',
  }) async {
    // Fetch products from the server
    try {
      final response = await ApiHelper.get(
        context,
        '/inventory/product',
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
      debugPrint('Fetched ${response.data['data']['data'].length} products');
      debugPrint(response.data['data'].toString());
      final result =
          (response.data['data']['data'] as List)
              .map((json) => Product.fromJSON(json))
              .toList();
      return result;
    } on DioException catch (e) {
      // Handle Error
      if (!context.mounted) return [];
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed:
            () => fetchProducts(
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

  static Future<Map<String, dynamic>?> fetchProductCode(
    BuildContext context,
    String barcode,
  ) async {
    try {
      final response = await ApiHelper.get(
        context,
        '/inventory/product-barcode/$barcode',
        params: {'store': context.read<AuthCubit>().state.storeId},
      );
      if (!response.data['success']) {
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      debugPrint(response.data['data'].toString());
      return response.data['data'];
    } on DioException catch (e) {
      if (!context.mounted) return null;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchProductCode(context, barcode),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchProductPurchase(
    BuildContext context,
    String barcode,
    bool isBroken,
  ) async {
    try {
      final response = await ApiHelper.get(
        context,
        '/transaction/product-purchase/$barcode',
        params: {
          'store': context.read<AuthCubit>().state.storeId,
          'is_broken': isBroken,
        },
      );
      if (!response.data['success']) {
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      debugPrint(response.data['data'].toString());
      return response.data['data'];
    } on DioException catch (e) {
      if (!context.mounted) return null;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchProductCode(context, barcode),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchProductOutside(
    BuildContext context,
    Map<String, dynamic> result,
  ) async {
    try {
      final response = await ApiHelper.get(
        context,
        '/transaction/purchase-non-product',
        params: {
          'store': context.read<AuthCubit>().state.storeId,
          'weight': result['weight'],
          'is_broken': result['is_broken'],
          'type_id': result['type_id'],
        },
      );
      if (!response.data['success']) {
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      debugPrint(response.data['data'].toString());
      return response.data['data'];
    } on DioException catch (e) {
      if (!context.mounted) return null;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchProductOutside(context, result),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchCheckProduct(
    BuildContext context,
    String barcode,
  ) async {
    try {
      final response = await ApiHelper.get(
        context,
        '/inventory/check-product/$barcode',
      );
      if (!response.data['success']) {
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      debugPrint('check product pertama ${response.data['data'].toString()} ');
      return response.data['data'];
    } on DioException catch (e) {
      if (!context.mounted) return null;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchCheckProduct(context, barcode),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }
}
