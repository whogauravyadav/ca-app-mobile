import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, guest, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final UserModel? user;
  final String? error;

  bool get isAdFree => user?.isAdFree == true;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._auth) : super(const AuthState()) {
    bootstrap();
  }

  final AuthService _auth;

  Future<void> bootstrap() async {
    if (_auth.isLoggedIn) {
      final cached = _auth.getCachedUser();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: cached,
      );
      try {
        final user = await _auth.fetchProfile();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } catch (_) {
        // Keep cached session; profile refresh can fail offline
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final user = await _auth.login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(error: apiErrorMessage(e));
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required List<String> exams,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final user = await _auth.register(
        name: name,
        email: email,
        phone: phone,
        exams: exams,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(error: apiErrorMessage(e));
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    List<String>? exams,
  }) async {
    try {
      final user = await _auth.updateProfile(
        name: name,
        phone: phone,
        exams: exams,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(error: apiErrorMessage(e));
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _auth.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: apiErrorMessage(e));
      return false;
    }
  }

  void continueAsGuest() {
    state = const AuthState(status: AuthStatus.guest);
  }

  void updateUser(UserModel user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      clearError: true,
    );
  }

  Future<void> logout() async {
    await _auth.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
