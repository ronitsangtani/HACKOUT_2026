import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

/// Provider for AuthRepository instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// StreamProvider exposing the Firebase User authentication state.
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// FutureProvider fetching the Firestore user profile for a given uid.
final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, uid) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getUserProfile(uid);
});

/// Controller handling async authentication mutations and UI loading/error states.
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  /// Sign in user with email and password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Register new user and create their Firestore document.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _authRepository.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Send password reset email.
  Future<bool> resetPassword({
    required String email,
  }) async {
    state = const AsyncLoading();
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Sign out current user.
  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _authRepository.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Provider for AuthController state and actions.
final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
