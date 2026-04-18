// lib/features/auth/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/auth_repository.dart';
import '../../../shared/models/auth_models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final AuthResponse? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    AuthResponse? user,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        user: clearUser ? null : user ?? this.user,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.login(email, password);
      // ======== تعيين المستخدم الجديد ========
      // كل الـ Providers التي تعتمد على authProvider ستتحدث تلقائياً
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
    String? connectionCode,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.register(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        role: role,
        connectionCode: connectionCode,
      );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    // ======== مسح المستخدم — كل الـ Providers تتحدث تلقائياً ========
    state = const AuthState();
  }

  String _parseError(dynamic e) {
    try {
      final msg = e.response?.data['message'];
      if (msg != null) return msg;
    } catch (_) {}
    return 'حدث خطأ، تأكد من الاتصال بالإنترنت';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final savedRoleProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authRepositoryProvider).getSavedRole();
});
