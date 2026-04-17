// lib/features/auth/data/auth_repository.dart
// مستودع المصادقة — يتعامل مع الـ API ويخزن بيانات الجلسة

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthRepository(this._apiClient);

  // ======== تسجيل الدخول ========
  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final authResponse = AuthResponse.fromJson(response.data['data']);
    await _saveSession(authResponse);
    return authResponse;
  }

  // ======== التسجيل ========
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
    String? connectionCode,
  }) async {
    final response = await _apiClient.dio.post('/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'role': role,
      if (connectionCode != null) 'connectionCode': connectionCode,
    });
    final authResponse = AuthResponse.fromJson(response.data['data']);
    await _saveSession(authResponse);
    return authResponse;
  }

  // ======== تخزين بيانات الجلسة في Secure Storage ========
  Future<void> _saveSession(AuthResponse auth) async {
    await _storage.write(key: AppConstants.tokenKey, value: auth.token);
    await _storage.write(key: AppConstants.userIdKey, value: auth.userId);
    await _storage.write(key: AppConstants.userRoleKey, value: auth.role);
    await _storage.write(key: AppConstants.userNameKey, value: auth.fullName);
    if (auth.patientProfileId != null) {
      await _storage.write(
          key: AppConstants.patientProfileIdKey,
          value: auth.patientProfileId.toString());
    }
  }

  // ======== تسجيل الخروج ========
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // ======== التحقق من وجود جلسة سابقة ========
  Future<String?> getSavedRole() async {
    return await _storage.read(key: AppConstants.userRoleKey);
  }

  Future<String?> getSavedToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<String?> getSavedName() async {
    return await _storage.read(key: AppConstants.userNameKey);
  }

  Future<int?> getSavedPatientProfileId() async {
    final val = await _storage.read(key: AppConstants.patientProfileIdKey);
    return val != null ? int.tryParse(val) : null;
  }
}
