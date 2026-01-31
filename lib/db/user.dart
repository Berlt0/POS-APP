import 'database.dart';
import '../utils/password_hashed.dart';
import 'package:pos_app/utils/hash_token.dart';

class UserDB {
  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    final db = await AppDatabase.database;

    final hashedPassword = PasswordHelper.hashPassword(password);

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final user = result.first;

    final userId = user['id'];
    if (userId == null) return null;

    // Generate raw token and store hashed version in DB
    final rawToken = TokenHelper.generateRawToken(userId as int);
    final hashedToken = TokenHelper.hashToken(rawToken);

    await db.update(
      'users',
      {'token': hashedToken},
      where: 'id = ?',
      whereArgs: [userId],
    );

    return {
     
      'userId': userId,
      'username': user['username'],
      'role': user['role'],
      'token': rawToken,
    };
    
  }


  Future<int?> getLoggedInUserId() async {
    final db = await AppDatabase.database;

    final List<Map<String, dynamic>> result = await db.query(
      'session',
      columns: ['user_id','username'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['user_id'] as int;
    } else {
      return null; 
    }
}

}
