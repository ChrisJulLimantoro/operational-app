import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/helper/auth_storage.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/helper/router.dart';

class ApiHelper {
  static Dio dio = Dio(
      BaseOptions(baseUrl: 'http://127.0.0.1:3000'),
    ) //local IP for testing
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Use navigatorKey.currentContext ONLY if it's available
            final currentContext = navigatorKey.currentContext;
            if (currentContext == null) {
              debugPrint(
                "Navigator context is null! Using only SharedPreferences.",
              );
            }

            // Fetch AuthState safely (either from Bloc or default values)
            final authState = currentContext?.read<AuthCubit>().state;
            final token =
                await AuthStorage.getToken(); // Load token from local storage

            options.headers['Authorization'] =
                token != null ? 'Bearer $token' : '';

            debugPrint("Auth State: $authState");

            if (authState?.storeId != null && authState?.companyId != null) {
              options.queryParameters.addAll({
                'auth': {
                  'store_id': authState!.storeId,
                  'company_id': authState.companyId,
                },
              });
            }

            handler.next(options);
          } catch (e) {
            debugPrint("Error in API interceptor: $e");
            handler.reject(DioException(requestOptions: options));
          }
        },
        onError: (DioException error, handler) async {
          // Check if response data is a Map
          if (error.response?.data is Map<String, dynamic>) {
            debugPrint('Error Response Data (JSON): ${error.response?.data}');
          } else {
            debugPrint(
              'Error Response Data: ${error.response?.data?.toString()}',
            );
          }

          if (error.response?.statusCode == 401) {
            await AuthStorage.clearAuthData();
            final currentContext = navigatorKey.currentContext;
            if (currentContext != null) {
              if (!currentContext.mounted) return;
              GoRouter.of(
                currentContext,
              ).go('/'); // Redirect to login if unauthorized
            }
          }
          handler.next(error);
        },
      ),
    );

  static Future<Response> get(
    BuildContext context,
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    return await dio.get(endpoint, queryParameters: params);
  }

  static Future<Response> post(
    BuildContext context,
    String endpoint, {
    dynamic data,
  }) async {
    return await dio.post(endpoint, data: data);
  }

  static Future<Response> put(
    BuildContext context,
    String endpoint, {
    dynamic data,
  }) async {
    return await dio.put(endpoint, data: data);
  }

  static Future<Response> delete(BuildContext context, String endpoint) async {
    return await dio.delete(endpoint);
  }
}
