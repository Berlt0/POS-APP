import 'database.dart';
import '../utils/password_hashed.dart';
import 'package:pos_app/utils/hash_token.dart';
import 'package:intl/intl.dart';

class Summary {

 Future<Map<String, dynamic>?> getLoggedInUserInfo() async {
    final db = await AppDatabase.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        se.id,
        se.user_id,
        se.username,
        se.role,

        us.email,
        us.contact_number,
        us.address
        us.created_at

      FROM session se
      LEFT JOIN users us
        ON us.id = se.user_id
      LIMIT 1
    ''');

  

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null; 
    }
}


}
 
