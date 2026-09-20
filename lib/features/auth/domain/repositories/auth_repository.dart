import '../entities/user.dart';

class LoginResult {
  final User usuario;
  final String token;

  const LoginResult({
    required this.usuario,
    required this.token,
  });
}

abstract class AuthRepository {
  Future<LoginResult> login({
    required String email,
    required String password,
  });
}