import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/helper/api.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/model/bank_account.dart'; // Import model BankAccount Anda
import 'package:operational_app/theme/colors.dart';

class BankAccountAPI {
  /// Mengambil semua daftar akun bank dari server.
  static Future<List<BankAccount>> fetchBankAccounts(
    BuildContext context, {
    String search = '', // Parameter opsional untuk pencarian
  }) async {
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState.storeId.isEmpty) {
        // Handle case where storeId is not available
        debugPrint("Auth Store ID is empty, cannot fetch bank accounts.");
        return [];
      }
      final storeId = authState.storeId;
      final response = await ApiHelper.get(
        context,
        '/transaction/bank_account/${storeId}/store', // Endpoint untuk daftar akun bank
        params: {'search': search}, // Hanya sertakan parameter pencarian
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
      print(response.data);
      final result = (response.data['data'] as List) // <-- Direct cast to List
          .map((json) => BankAccount.fromJSON(json))
          .toList();
      debugPrint('Fetched ${result.length} bank accounts');
      return result;
    } on DioException catch (e) {
      if (!context.mounted) return [];
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil data Akun Bank",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchBankAccounts(
          context,
          search: search,
        ),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return [];
    }
  }

  /// Mengambil detail satu akun bank berdasarkan ID.
  static Future<BankAccount?> fetchBankAccount(
    BuildContext context,
    String id,
  ) async {
    try {
      final response =
          await ApiHelper.get(context, '/transaction/bank_account/$id');
      if (!response.data['success']) {
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      return BankAccount.fromJSON(response.data['data']);
    } on DioException catch (e) {
      if (!context.mounted) return null;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal mengambil detail Akun Bank",
        message:
            "${e.response?.data['message'] ?? "Gagal Mengambil data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => fetchBankAccount(context, id),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return null;
    }
  }

  /// Membuat akun bank baru.
  static Future<bool> createBankAccount(
    BuildContext context,
    BankAccount bankAccount,
  ) async {
    try {
      final response = await ApiHelper.post(
        context,
        '/transaction/bank_account',
        data: bankAccount.toJSON(),
      );

      if (!context.mounted) return false;

      if (response.data['success']) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Sukses!",
          message: "Akun Bank berhasil ditambahkan.",
          primaryButtonText: "OK",
          onPrimaryPressed: () => {},
          icon: Icons.check_circle_outline,
          primaryColor: AppColors.bluePrimary,
        );
        return true;
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal Menambahkan Akun Bank",
          message: response.data['message'] ?? "Terjadi kesalahan.",
          primaryButtonText: "OK",
          onPrimaryPressed: () => {},
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
        );
        return false;
      }
    } on DioException catch (e) {
      if (!context.mounted) return false;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal Menambahkan Akun Bank",
        message:
            "${e.response?.data['message'] ?? "Gagal menambahkan data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => createBankAccount(context, bankAccount),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }

  /// Memperbarui akun bank yang sudah ada.
  static Future<bool> updateBankAccount(
    BuildContext context,
    BankAccount bankAccount,
  ) async {
    try {
      final response = await ApiHelper.put(
        context,
        '/transaction/bank_account/${bankAccount.id}',
        data: bankAccount.toJSON(),
      );

      if (!context.mounted) return false;

      if (response.data['success']) {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Sukses!",
          message: "Akun Bank berhasil diperbarui.",
          primaryButtonText: "OK",
          onPrimaryPressed: () => {},
          icon: Icons.check_circle_outline,
          primaryColor: AppColors.bluePrimary,
        );
        return true;
      } else {
        NotificationHelper.showNotificationSheet(
          context: context,
          title: "Gagal Memperbarui Akun Bank",
          message: response.data['message'] ?? "Terjadi kesalahan.",
          primaryButtonText: "OK",
          onPrimaryPressed: () => {},
          icon: Icons.error_outline,
          primaryColor: AppColors.error,
        );
        return false;
      }
    } on DioException catch (e) {
      if (!context.mounted) return false;
      NotificationHelper.showNotificationSheet(
        context: context,
        title: "Gagal Memperbarui Akun Bank",
        message:
            "${e.response?.data['message'] ?? "Gagal memperbarui data karena jaringan lemah!"}",
        primaryButtonText: "Retry",
        onPrimaryPressed: () => updateBankAccount(context, bankAccount),
        icon: Icons.error_outline,
        primaryColor: AppColors.error,
      );
      return false;
    }
  }
}
