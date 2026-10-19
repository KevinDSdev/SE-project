import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'Mobile Developer',
  });
}

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock validation
    if (email.contains('@') && password.length >= 6) {
      final name = email.split('@').first;
      final capitalized =
          name.isNotEmpty ? '${name[0].toUpperCase()}${name.substring(1)}' : 'User';
      state = AuthState(
        user: UserModel(
          id: 'usr_001',
          name: capitalized,
          email: email,
        ),
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid credentials. Password must be at least 6 characters.',
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 800));

    if (name.isNotEmpty && email.contains('@') && password.length >= 6) {
      state = AuthState(
        user: UserModel(
          id: 'usr_002',
          name: name,
          email: email,
        ),
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please provide valid information to create an account.',
      );
      return false;
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
