import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/profit_loss.dart';
import 'package:operational_app/theme/colors.dart';
import 'dart:convert';

class ProfitLossAPI {
  // Fetching Transaction FROM API
  static Future<List<PLSection>> fetchPLDataFromAPI(
    BuildContext context, {
    String? ownerId,
    String? store,
    String? companyID,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> params = {
        if (ownerId != null && ownerId.isNotEmpty) 'owner_id': ownerId,
        if (store != null && store.isNotEmpty) 'store': store,
        if (companyID != null && companyID.isNotEmpty) 'company_id': companyID,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };

      final response = await ApiHelper.get(
        context,
        '/finance/profit-loss',
        params: params,
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
          .map((json) => PLSection.fromJson(json))
          .toList();
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed:
            () => fetchPLDataFromAPI(
              context,
              ownerId: ownerId,
              store: store,
              companyID: companyID,
              startDate: startDate,
              endDate: endDate,
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
            () => fetchPLDataFromAPI(
              context,
              ownerId: ownerId,
              store: store,
              companyID: companyID,
              startDate: startDate,
              endDate: endDate,
            ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }

  /// 🔥 Generate Profit Loss PDF from API
  static Future<List<int>?> generatePDF({
    required BuildContext context,
    required Map<String, dynamic> filters,
  }) async {
    try {
      final response = await ApiHelper.dio.post(
        '/finance/pdf-profit-loss',
        data: filters,
        options: Options(
          responseType: ResponseType.json,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final decoded = response.data; // Already a Map<String, dynamic>
      debugPrint("Decoded response: $decoded");

      if (decoded['success'] == true) {
        final base64String = decoded['data']['pdf']; // adjust if key name is different
        final pdfBytes = base64Decode(base64String);
        return pdfBytes;
      } else {
        debugPrint("PDF generation failed: $decoded");
        return null;
      }
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        primaryButtonText: "Retry",
        onPrimaryPressed: () => generatePDF(context: context, filters: filters),
        title: "Gagal generate PDF",
        message:
            "${e.response?.data['message'] ?? "Terjadi kesalahan saat mengunduh PDF."}",
        icon: Icons.picture_as_pdf,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }
}
