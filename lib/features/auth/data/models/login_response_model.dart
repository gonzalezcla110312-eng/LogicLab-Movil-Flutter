import '../../domain/entities/user.dart';

class LoginResponseModel {
  final String token;
  final UserModel usuario;

  const LoginResponseModel({
    required this.token,
    required this.usuario,
  });

  factory LoginResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LoginResponseModel(
      token: json['token'] as String,
      usuario: UserModel.fromJson(
        json['usuario'] as Map<String, dynamic>,
      ),
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id'] as int,
      name: json['nombre'] as String,
      lastName: json['apellido'] as String,
      email: json['email'] as String,
      role: json['rol'] as String,
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      lastName: lastName,
      email: email,
      role: role,
    );
  }
}