import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/account.dart';
import 'package:operational_app/model/account_settings.dart';
import 'package:operational_app/theme/colors.dart';

class AccountsApi {
  // Fetching Transaction FROM API
  static Future<List<Account>> fetchAccountFromAPI(
    BuildContext context,
    {
    String? search,
    String? accountTypeId
  }) async {
    try {
      final uri = '/finance/account';
      final response = await ApiHelper.get(
        context,
        uri,
        params: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (accountTypeId != null && accountTypeId.isNotEmpty) 'account_type_id': accountTypeId,
        }
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
          .map((json) => Account.fromJSON(json))
          .toList();
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed:
            () => fetchAccountFromAPI(
              context,
              search: search,
              accountTypeId: accountTypeId,
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
            () => fetchAccountFromAPI(
              context,
              search: search,
              accountTypeId: accountTypeId,
            ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }

// Fetch Account Settings From API
  static Future<List<AccountSetting>> fetchAccountSetting(
    BuildContext context,
    {
    String? search,
    String action = "purchaseCust",
  }) async {
    try {
      final uri = '/finance/trans-account-setting-action/$action';
      final response = await ApiHelper.get(
        context,
        uri,
        params: {
          if (search != null && search.isNotEmpty) 'search': search,
        }
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
          .map((json) => AccountSetting.fromJSON(json))
          .toList();
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed:
            () => fetchAccountSetting(
              context,
              search: search,
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
            () => fetchAccountSetting(
              context,
              search: search,
            ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }
}