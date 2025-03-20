import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/operation.dart';
import 'package:operational_app/theme/colors.dart';

class OperationAPI {
  static Future<List<Operation>> fetchOperations(
    BuildContext context,
    int page,
    int limit,
  ) async {
    // Fetch products from the server
    try {
      final response = await ApiHelper.get(
        context,
        '/inventory/operation',
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
      debugPrint('Fetched ${response.data['data']['data'].length} operations');
      debugPrint(response.data['data'].toString());
      final result =
          (response.data['data']['data'] as List)
              .map((json) => Operation.fromJSON(json))
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
        onPrimaryPressed: () => fetchOperations(context, page, limit),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }

  static Future<Operation?> fetchOperation(
    BuildContext context,
    String id,
  ) async {
    // Fetch a single operation from the server
    try {
      final response = await ApiHelper.get(context, '/inventory/operation/$id');
      if (!response.data['success']) {
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      return Operation.fromJSON(response.data['data']);
    } on DioException catch (e) {
      // Handle Error
      if (!context.mounted) return null;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchOperation(context, id),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }
}
