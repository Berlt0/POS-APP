import 'database.dart';
import '../utils/password_hashed.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';


class UserSeed {
  static Future<void> seed() async {
    final db = await AppDatabase.database;

    // Check if users already exist
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    );

    if (count != null && count > 0) return;

    // Format date and time
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    await db.insert('users', {
      'username': 'admin',
      'password': PasswordHelper.hashPassword('admin21034'),
      'role': 'owner',
      'createdAt': now,
    });


    print('Default users inserted with createdAt: $now');
  }
}
