import 'package:flutter_bloc/flutter_bloc.dart';
import '../helper/auth_storage.dart';

class AuthState {
  final String storeId;
  final String companyId;

  AuthState({required this.storeId, required this.companyId});
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState(storeId: '', companyId: ''));

  Future<void> loadAuthParams() async {
    final authData = await AuthStorage.getAuthData();
    emit(
      AuthState(
        storeId: authData['store_id'] ?? '',
        companyId: authData['company_id'] ?? '',
      ),
    );
  }

  Future<void> updateStoreAndCompany(String storeId, String companyId) async {
    await AuthStorage.updateStoreAndCompany(storeId, companyId);
    emit(AuthState(storeId: storeId, companyId: companyId));
  }
}
