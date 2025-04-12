import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/store.dart';
import 'package:operational_app/theme/colors.dart';

class StoreAPI {
  static Future<List<Store>> fetchStores(
    BuildContext context, {
    int page = 0,
    int limit = 0,
    String search = "",
  }) async {
    try {
      final response = await ApiHelper.get(
        context,
        '/master/store',
        params: {'page': page, 'limit': limit, 'search': search},
      );
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
          (response.data['data']['data'] as List)
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
        onPrimaryPressed:
            () =>
                fetchStores(context, page: page, limit: limit, search: search),
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
            () =>
                fetchStores(context, page: page, limit: limit, search: search),
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
      debugPrint(result.toString());
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

  static Future<List<Store>> fetchActiveStore(BuildContext context) async {
    try {
      final response = await ApiHelper.get(context, '/auth/authorized-store');
      if (!response.data['success']) {
        return [];
      }
      if (!context.mounted) {
        return [];
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }

      List<Store> result = [];

      for (var company in response.data['data'] as List) {
        Map<String, dynamic> companyCopy = Map.of(company)..remove('stores');
        final storeList = company['stores'] as List<dynamic>? ?? [];

        for (var store in storeList) {
          result.add(Store.fromJSON({...store, 'company': companyCopy}));
        }
      }

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
}
