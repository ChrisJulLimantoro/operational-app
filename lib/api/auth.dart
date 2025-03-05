import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
}
