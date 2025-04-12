import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/api/auth.dart';
import 'package:operational_app/bloc/auth_bloc.dart';

class PermissionState {
  final List<dynamic> permissions;
  final bool isLoading;

  PermissionState({required this.permissions, this.isLoading = false});
}

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(PermissionState(permissions: []));

  Future<void> fetchPermissions(BuildContext context) async {
    emit(PermissionState(permissions: [], isLoading: true));

    // Context call
    final authState = context.read<AuthCubit>().state;
    if (authState.storeId.isEmpty) {
      emit(PermissionState(permissions: []));
      return;
    }

    try {
      // Replace this with your actual API call
      final response = await AuthAPI.fetchPermission(context);

      emit(PermissionState(permissions: response));
    } catch (e) {
      // Handle error if needed
      emit(PermissionState(permissions: []));
    }
  }

  void clearPermissions() {
    emit(PermissionState(permissions: []));
  }
}

extension PermissionHelper on PermissionState {
  bool hasPermission(String feature, String action) {
    return permissions.any(
      (perm) =>
          perm['path'] == feature && [action, 'all'].contains(perm['action']),
    );
  }

  List<String> actions(String feature) {
    return permissions.where((perm) => perm['path'] == feature).map((perm) {
      return perm['action'] as String;
    }).toList();
  }
}
