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
  final bool isInitialized;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isInitialized = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    AuthResponse? user,
    bool? isInitialized,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        user: clearUser ? null : user ?? this.user,
        isInitialized: isInitialized ?? this.isInitialized,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final token = await _repo.getSavedToken();
      final role = await _repo.getSavedRole();
      final name = await _repo.getSavedName();
      final profileId = await _repo.getSavedPatientProfileId();

      if (token != null && role != null) {
        final restoredUser = AuthResponse(
          token: token,
          userId: '',
          fullName: name ?? '',
          email: '',
          role: role,
          patientProfileId: profileId,
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        );
        state = state.copyWith(user: restoredUser, isInitialized: true);
      } else {
        state = state.copyWith(isInitialized: true);
      }
    } catch (_) {
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.login(email, password);
      state = state.copyWith(isLoading: false, user: user, isInitialized: true);
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
      state = state.copyWith(isLoading: false, user: user, isInitialized: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(isInitialized: true);
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
