import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/login_response_model.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/usuarios/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final exito = data['exito'] as bool? ?? false;

    if (!exito) {
      throw AuthException(
        data['error'] as String? ?? 'Error al iniciar sesión',
      );
    }

    return LoginResponseModel.fromJson(data);
  }
}