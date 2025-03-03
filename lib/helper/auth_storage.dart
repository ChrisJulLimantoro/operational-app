import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _storeIdKey = 'store_id';
  static const _companyIdKey = 'company_id';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';
  static const _isOwnerKey = 'is_owner';

  static Future<void> saveAuthData(
    String token,
    String storeId,
    String companyId,
    String userId,
    String userEmail,
    bool isOwner,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_storeIdKey, storeId);
    await prefs.setString(_companyIdKey, companyId);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, userEmail);
    await prefs.setBool(_isOwnerKey, isOwner);
  }

  static Future<void> saveData(
    String storeId,
    String companyId,
    String userId,
    String userEmail,
    bool isOwner,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeIdKey, storeId);
    await prefs.setString(_companyIdKey, companyId);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, userEmail);
    await prefs.setBool(_isOwnerKey, isOwner);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print("Stored Token: $token"); // Debugging
    return token;
  }

  static Future<Map<String, dynamic>> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'store_id': prefs.getString(_storeIdKey),
      'company_id': prefs.getString(_companyIdKey),
      'user_id': prefs.getString(_userIdKey),
      'user_email': prefs.getString(_userEmailKey),
      'is_owner': prefs.getBool(_isOwnerKey),
    };
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_storeIdKey);
    await prefs.remove(_companyIdKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_isOwnerKey);
  }

  static Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }
}
