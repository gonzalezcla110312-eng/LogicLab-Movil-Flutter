import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return DioClient(getToken: storage.getToken).dio;
});

final authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(dioProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
  );
});

final loginProvider = Provider<Login>((ref) {
  return Login(
    ref.watch(authRepositoryProvider),
  );
});

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? usuario;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.usuario,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        usuario = null,
        errorMessage = null;

  AuthState copyWith({
    AuthStatus? status,
    User? usuario,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      usuario: usuario ?? this.usuario,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState(
      status: AuthStatus.loading,
    );

    try {
      final result = await ref.read(loginProvider)(
        email: email,
        password: password,
      );

      await ref.read(tokenStorageProvider).saveToken(
            token: result.token,
          );

      state = AuthState(
        status: AuthStatus.authenticated,
        usuario: result.usuario,
      );
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } on DioException catch (e) {
      String message = 'Error al iniciar sesión';

      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['error'] is String) {
        message = data['error'] as String;
      } else if (e.response?.statusCode == 401) {
        message = 'Correo o contraseña incorrectos';
      } else if (e.response?.statusCode == 500) {
        message = 'Error interno del servidor';
      }

      state = AuthState(
        status: AuthStatus.error,
        errorMessage: message,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Ocurrió un error inesperado',
      );
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();

    state = const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);