import 'package:flutter_riverpod/flutter_riverpod.dart';

// ViewModel State
class AuthState {
  final bool isLoading;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be null to clear error
    );
  }
}

// ViewModel (Notifier)
class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // TODO: Connect to real Repository later
      
      state = state.copyWith(isLoading: false);
      return true; // Success
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false; // Failed
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // TODO: Connect to real Repository later
      
      state = state.copyWith(isLoading: false);
      return true; // Success
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false; // Failed
    }
  }
}

// Global Provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
