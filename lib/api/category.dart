import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/category.dart';
import 'package:operational_app/theme/colors.dart';

class CategoryAPI {
  static Future<List<Category>> fetchCategories(BuildContext context) async {
    try {
      final response = await ApiHelper.get(context, '/inventory/category');
      print(response.data);
      if (!response.data['success']) {
        return [];
      }
      if (!context.mounted) {
        return [];
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      final result =
          (response.data['data'] as List)
              .map((json) => Category.fromJSON(json))
              .toList();
      return result;
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchCategories(context),
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
        onPrimaryPressed: () => fetchCategories(context),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }
}
