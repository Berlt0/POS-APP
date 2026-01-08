import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveSession(int userId, String token) async {
    await _storage.write(key: 'userId', value: userId.toString());
    await _storage.write(key: 'token', value: token);
  }

  static Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      // if secure storage fails for any reason, treat as logged out
      return false;
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userId');
  }

  static Future<int?> getUserId() async {
    final userId = await _storage.read(key: 'userId');
    return userId != null ? int.tryParse(userId) : null;
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
}
