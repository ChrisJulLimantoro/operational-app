import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/stock_mutation.dart';
import 'package:operational_app/theme/colors.dart';

class StockMutationAPI {
  /// ✅ Fetch Stock Mutation Data from API
  static Future<List<StockMutation>> fetchStockMutations(
    BuildContext context, {
    String? store,
    String? categoryID,
    DateTime? dateStart,
    DateTime? dateEnd,
  }) async {
    try {
      final Map<String, dynamic> params = {
        if (store != null && store.isNotEmpty) 'store_id': store,
        if (categoryID != null && categoryID.isNotEmpty) 'category_id': categoryID,
        if (dateStart != null) 'dateStart': dateStart.toIso8601String(),
        if (dateEnd != null) 'dateEnd': dateEnd.toIso8601String(),
      };

      final response = await ApiHelper.get(
        context,
        '/finance/stock-mutation',
        params: params,
      );
      debugPrint("stock mutation fetch api: ${response.data}");

      if (!response.data['success']) return [];
      if (!context.mounted) return [];

      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }

      return (response.data['data'] as List)
          .map((json) => StockMutation.fromJSON(json))
          .toList();
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchStockMutations(
          context,
          store: store,
          categoryID: categoryID,
          dateStart: dateStart,
          dateEnd: dateEnd,
        ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    } catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message: "$e",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchStockMutations(
          context,
          store: store,
          categoryID: categoryID,
          dateStart: dateStart,
          dateEnd: dateEnd,
        ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }
}
