import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:gircik/core/network/api_client.dart';
import 'package:gircik/data/models/user.dart';

// ViewModel State
class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      user: user ?? this.user,
    );
  }
}

// ViewModel (Notifier)
class AuthViewModel extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    _checkAuthStatus();
    return AuthState();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      // Not logged in or token invalid
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.login(email, password);
      // Fetch user profile after login
      final user = await _repository.getCurrentUser();
      state = state.copyWith(isLoading: false, user: user);
      return true; // Success
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false; // Failed
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.register(name, email, password);
      // Auto-login after registration
      return await login(email, password, true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false; // Failed
    }
  }
  
  Future<void> logout() async {
    await _repository.logout();
    state = AuthState(); // Reset state
  }
}

// Global Provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});

