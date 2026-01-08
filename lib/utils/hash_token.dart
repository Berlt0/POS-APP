import 'dart:convert';
import 'package:crypto/crypto.dart';

class TokenHelper {
  static String generateRawToken(int userId) {
    final data = '$userId-${DateTime.now().millisecondsSinceEpoch}';
    return data;
  }

  static String hashToken(String token) {
    final bytes = utf8.encode(token);
    return sha256.convert(bytes).toString();
  }
}
