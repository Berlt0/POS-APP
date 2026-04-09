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
      'global_id': '00000000-0000-0000-0000-000000000001',
      'username': 'admin',
      'password': PasswordHelper.hashPassword('admin21034'),
      'role': 'admin',
      'name': 'Admin Kuno',
      'email': 'admin21@gmail.com',
      'contact_number': '09123456789',
      'address': 'Zamboanga del Sur, Pagadian City',
      'createdAt': now,
    });

    await db.insert('users', {
      'global_id':'00000000-0000-0000-0000-000000000002',
      'username': 'john',
      'password': PasswordHelper.hashPassword('johnpass21'),
      'role': 'cashier',
      'name': 'John Erps',
      'email': 'johny2@gmail.com',
      'contact_number': '0922435010',
      'address': 'Zamboanga del Sur, Pagadian City',
      'createdAt': now,
    });


    print('Default users inserted with createdAt: $now');
  }
}
