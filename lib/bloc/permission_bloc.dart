import 'package:flutter_bloc/flutter_bloc.dart';

class PermissionState {
  final List<Map<String, dynamic>> permissions;
  final bool isLoading;

  PermissionState({required this.permissions, this.isLoading = false});
}

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(PermissionState(permissions: []));

  Future<void> fetchPermissions(String storeId, String companyId) async {
    emit(PermissionState(permissions: [], isLoading: true));

    // try {
    // final newPermissions = await fetchPermissionsFromAPI(storeId, companyId);
    // emit(PermissionState(permissions: newPermissions));
    // } catch (e) {
    // emit(PermissionState(permissions: [])); // Reset on failure
    // }
  }

  void clearPermissions() {
    emit(PermissionState(permissions: []));
  }
}
