import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/auth_storage.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/theme/colors.dart';

class AuthAPI {
  static Future<bool> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    // Call Login API
    try {
      final response = await ApiHelper.post(
        context,
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }

      final Map<String, dynamic> responseData = response.data;

      if (responseData.containsKey('success') &&
          responseData['success'] == true) {
        final data = responseData['data'];

        await AuthStorage.saveAuthData(
          data['token'],
          data['store_id'],
          data['company_id'],
          data['id'],
          data['email'],
          data['is_owner'],
        );

        // Save storeId, companyId, userId, userEmail, isOwner to SharedPreferences
        if (!context.mounted) {
          return true;
        }
        final authCubit = context.read<AuthCubit>();
        authCubit.updateAuth(
          context,
          data['store_id'],
          data['company_id'],
          data['id'],
          data['email'],
          data['is_owner'],
        );

        // Redirect user to home screen
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      debugPrint("Error: $e");
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        NotificationHelper.showSnackbar(
          message: "Connection timeout. Please try again.",
          backgroundColor: AppColors.error,
          actionLabel: "Retry",
          onActionPressed: () => login(context, email, password),
        );
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Login Gagal",
          message: e.response?.data['message'] ?? "Gagal Masuk",
          primaryButtonText: "Coba Lagi",
          onPrimaryPressed: () {},
        );
      }
      return false;
    }
  }

  static Future<void> changePassword(
    BuildContext context,
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final res = await ApiHelper.post(
        context,
        '/auth/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          "confirm_password": confirmPassword,
        },
      );

      if (res.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      if (!res.data['success']) {
        throw Exception("Failed to change password");
      }
      if (!context.mounted) return;

      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Password Changed",
        message: "Password changed successfully",
        primaryButtonText: "OK",
        primaryColor: AppColors.success,
        icon: Icons.check_circle_outline,
        onPrimaryPressed: () {
          GoRouter.of(context).pop(context);
        },
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        NotificationHelper.showSnackbar(
          message: "Connection timeout. Please try again.",
          backgroundColor: AppColors.error,
          actionLabel: "Retry",
          onActionPressed:
              () => changePassword(
                context,
                oldPassword,
                newPassword,
                confirmPassword,
              ),
        );
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Login Gagal",
          message: e.response?.data['message'] ?? "Gagal Masuk",
          primaryButtonText: "Coba Lagi",
          onPrimaryPressed: () {},
        );
      }
      return;
    }
  }
}
