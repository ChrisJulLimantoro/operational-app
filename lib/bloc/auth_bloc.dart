import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/model/store.dart';
import '../helper/auth_storage.dart';

class AuthState {
  final String storeId;
  final String companyId;
  final String userId;
  final String userEmail;
  final bool isOwner;

  AuthState({
    required this.storeId,
    required this.companyId,
    required this.userId,
    required this.userEmail,
    required this.isOwner,
  });
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit()
    : super(
        AuthState(
          storeId: "",
          companyId: "",
          userId: "",
          userEmail: "",
          isOwner: false,
        ),
      );

  Future<void> loadAuthParams(BuildContext context) async {
    final authData = await AuthStorage.getAuthData();
    emit(
      AuthState(
        storeId: authData['store_id'] ?? '',
        companyId: authData['company_id'] ?? '',
        userId: authData['user_id'] ?? '',
        userEmail: authData['user_email'] ?? '',
        isOwner: authData['is_owner'] ?? false,
      ),
    );
  }

  Future<void> changeActiveStore(Store store) async {
    await AuthStorage.saveData(
      store.id,
      store.company.id,
      state.userId,
      state.userEmail,
      state.isOwner,
    );
    emit(
      AuthState(
        storeId: store.id,
        companyId: store.company.id,
        userId: state.userId,
        userEmail: state.userEmail,
        isOwner: state.isOwner,
      ),
    );
  }

  Future<void> updateAuth(
    BuildContext context,
    String storeId,
    String companyId,
    String userId,
    String userEmail,
    bool isOwner,
  ) async {
    await AuthStorage.saveData(storeId, companyId, userId, userEmail, isOwner);
    emit(
      AuthState(
        storeId: storeId,
        companyId: companyId,
        userId: userId,
        userEmail: userEmail,
        isOwner: isOwner,
      ),
    );
  }

  Future<void> logout() async {
    await AuthStorage.clearAuthData();
    emit(
      AuthState(
        storeId: "",
        companyId: "",
        userId: "",
        userEmail: "",
        isOwner: false,
      ),
    );
  }
}
