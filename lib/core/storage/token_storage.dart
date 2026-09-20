import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage storage;

  TokenStorage({
    FlutterSecureStorage? storage,
  }) : storage = storage ?? const FlutterSecureStorage();

  static const String tokenKey = 'token';
  Future<void> saveToken({
    required String token,
  }) async {
    await storage.write(
      key: tokenKey,
      value: token,
    );
  }

  Future<String?> getToken() {
    return storage.read(
      key: tokenKey,
    );
  }

  // Removed getRefreshToken method

  Future<void> clear() async {
    await storage.delete(
      key: tokenKey,
    );
  }
}