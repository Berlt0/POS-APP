import 'database.dart';

class ManageAccess{

  Future<List<Map<String,dynamic>>> getCashiers() async {

    try {
      
      final db = await AppDatabase.database;

      final  cashiers = await db.rawQuery(
        '''
          SELECT * FROM users
          WHERE role = ? 
          AND deleted_at IS NULL
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


  Future<bool> removeCashier(int id, String name) async {

    try {
      
      final db = await AppDatabase.database;

      final now = DateTime.now().toIso8601String();

      final remove = await db.rawUpdate(
        '''
          UPDATE users SET deleted_at = ?, is_synced = ? WHERE id = ? AND name = ? 
        ''', [now,0,id,name]); 

        return remove > 0;

    } catch (error) {
      
      print("Failed to remove cashier: $error");
      return false;
    }

  }




}