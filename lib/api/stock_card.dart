import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/stock_card.dart';
import 'package:operational_app/theme/colors.dart';

class StockCardAPI {
  /// ✅ Fetch Stock Mutation Data from API
  static Future<List<StockCard>> fetchStockCards(
    BuildContext context, {
    String? productID,
    DateTime? dateStart,
    DateTime? dateEnd,
    String? productCode,
  }) async {
    try {
      final Map<String, dynamic> params = {
        if (productID != null && productID.isNotEmpty) 'product_id': productID,
        if (productCode != null && productCode.isNotEmpty) 'product_code_code': productCode,
        if (dateStart != null) 'dateStart': dateStart.toIso8601String(),
        if (dateEnd != null) 'dateEnd': dateEnd.toIso8601String(),
      };

      final response = await ApiHelper.get(
        context,
        '/finance/stock-card',
        params: params,
      );
      debugPrint("stock mutation fetch api: ${response.data}");

      if (!response.data['success']) return [];
      if (!context.mounted) return [];

      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }

      return (response.data['data'] as List)
          .map((json) => StockCard.fromJSON(json))
          .toList();
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchStockCards(
          context,
          productID: productID,
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
        onPrimaryPressed: () => fetchStockCards(
          context,
          productID: productID,
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
