import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/store.dart';
import 'package:operational_app/theme/colors.dart';

class StoreAPI {
  static Future<List<Store>> fetchStores(BuildContext context) async {
    try {
      final response = await ApiHelper.get(context, '/master/store');
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
              .map((json) => Store.fromJSON(json))
              .toList();
      return result;
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchStores(context),
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
        onPrimaryPressed: () => fetchStores(context),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }

  static Future<Store?> fetchStore(BuildContext context, String id) async {
    try {
      final response = await ApiHelper.get(context, '/master/store/$id');
      if (!response.data['success']) {
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      final result = Store.fromJSON(response.data['data']);
      return result;
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchStore(context, id),
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
        onPrimaryPressed: () => fetchStore(context, id),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }
}
