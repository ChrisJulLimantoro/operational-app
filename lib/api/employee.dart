import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/employee.dart';
import 'package:operational_app/theme/colors.dart';

class EmployeeAPI {
  static Future<List<Employee>> fetchEmployees(
    BuildContext context, {
    int page = 0,
    int limit = 0,
    String search = '',
  }) async {
    try {
      final response = await ApiHelper.get(
        context,
        '/master/employee',
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
              .map((json) => Employee.fromJSON(json))
              .toList();
      return result;
    } on DioException catch (e) {
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchEmployees(context),
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
        onPrimaryPressed: () => fetchEmployees(context),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }
}
