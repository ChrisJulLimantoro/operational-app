import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/product.dart';
import 'package:operational_app/theme/colors.dart';

class ProductAPI {
  static Future<List<Product>> fetchProducts(
    BuildContext context,
    int page,
    int limit,
  ) async {
    // Fetch products from the server
    try {
      final response = await ApiHelper.get(
        context,
        '/inventory/product',
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
        onPrimaryPressed: () => fetchProducts(context, page, limit),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }
}
