import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/customer.dart';
import 'package:operational_app/theme/colors.dart';

class CustomerAPI {
  static Future<List<Customer>> fetchCustomers(BuildContext context) async {
    try {
      final response = await ApiHelper.get(context, '/transaction/customer');
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
              .map((json) => Customer.fromJSON(json))
              .toList();
      return result;
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchCustomers(context),
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
        onPrimaryPressed: () => fetchCustomers(context),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }

  static Future<Customer?> fetchCustomer(
    BuildContext context,
    String id,
  ) async {
    try {
      final response = await ApiHelper.get(
        context,
        '/transaction/customer/$id',
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
      return Customer.fromJSON(response.data['data']);
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchCustomers(context),
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
        onPrimaryPressed: () => fetchCustomers(context),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }

  static Future<Customer?> fetchCustomerByEmail(
    BuildContext context,
    String email,
  ) async {
    try {
      final response = await ApiHelper.get(
        context,
        '/transaction/customer-email/$email',
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
      return Customer.fromJSON(response.data['data']);
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchCustomerByEmail(context, email),
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
        onPrimaryPressed: () => fetchCustomerByEmail(context, email),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }
}
