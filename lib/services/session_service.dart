import 'package:sqflite/sqflite.dart';
import '../db/database.dart';

class SessionService {
  // Save logged-in user info
  static Future<void> saveSession({
    required int userId,
    required String username,
    required String role,
  }) async {
    final db = await AppDatabase.database;

    await db.insert(
      'session',
      {
        'user_id': userId,
        'username': username,
        'role': role,
        'login_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get logged-in user
  static Future<Map<String, dynamic>?> getSession() async {
    final db = await AppDatabase.database;
    final result = await db.query('session', limit: 1);

    if (result.isEmpty) return null;
    return result.first;
  }

  // Logout
  static Future<void> clearSession() async {
    final db = await AppDatabase.database;
    await db.delete('session');
  }
}
