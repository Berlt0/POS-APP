import 'database.dart';
import '../utils/password_hashed.dart';
import 'package:intl/intl.dart';

class UserDB {
  static Future<Map<String, dynamic>?> login(String username,String password,) async {
    
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

    
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    await db.delete('session');

    await db.insert('session', {
      'user_id': userId,
      'user_global_id': user['global_id'],
      'username': user['username'],
      'role': user['role'], 
      'login_at': now,
      'is_synced': 0
    });

    return {
     
      'userId': userId,
      'user_global_id': user['global_id'],
      'username': user['username'],
      'role': user['role'],
    };
    
  }



  Future<int?> getLoggedInUserId() async {
    final db = await AppDatabase.database;

    final List<Map<String, dynamic>> result = await db.query(
      'session',
      columns: ['user_id', 'user_global_id','username','role'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['user_id'] as int;
    } else {
      return null; 
    }
}



Future<String?> getLoggedInUserRole() async {
  final db = await AppDatabase.database;

  final result = await db.query(
    'session',
    columns: ['role'],
    limit: 1,
  );

  if (result.isEmpty) return null;

  return result.first['role']?.toString();
}


Future<String?> getLoggedInUserGlobalId() async {
  final db = await AppDatabase.database;

  final result = await db.query(
    'session',
    columns: ['user_global_id'],
    limit: 1,
  );

  if (result.isEmpty) return null;

  return result.first['user_global_id']?.toString();
}

}


