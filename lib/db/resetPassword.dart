import 'database.dart';

class ResetPassword {

  Future<List<Map<String,dynamic>>> getCashiers() async {

    try {
      
      final db = await AppDatabase.database;

      final  cashiers = await db.rawQuery(
        '''
          SELECT * FROM users
          WHERE role = ? AND 
          deleted_at IS NULL
        ''',['cashier']);


        return cashiers;


    } catch (error) {
      
      print("Unable to fetch cashiers");
      throw Exception("Failed to fetch cashier.");

    }

  }

  Future<bool> resetPassword({
    required String name,
    required String password
  }) async {

    try {
      
      final db = await AppDatabase.database;

      final reset = await db.rawUpdate(
        '''
        UPDATE users SET password = ? WHERE name = ?
        ''',[password,name]);

      return reset > 0;

    } catch (error) {
   
      print("Failed to reset password: $error");
      return false;
    }

  }



}