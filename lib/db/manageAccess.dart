import 'database.dart';

class ManageAccess{

  Future<List<Map<String,dynamic>>> getCashiers() async {

    try {
      
      final db = await AppDatabase.database;

      final  cashiers = await db.rawQuery(
        '''
          SELECT * FROM users
          WHERE role = ? 
        ''',['cashier']);


        return cashiers;


    } catch (error) {
      
      print("Unable to fetch cashiers");
      throw Exception("Failed to fetch cashier.");

    }

  }


  Future<bool> toggleCashierStatus({
    required int id,
    required int isDisabled,
  }) async {
    try {
      final db = await AppDatabase.database;

      final result = await db.rawUpdate('''
        UPDATE users
        SET is_disabled = ?
        WHERE id = ?
      ''', [isDisabled, id]);

      return result > 0;
    } catch (e) {
      print("Toggle failed: $e");
      return false;
    }
  }


}