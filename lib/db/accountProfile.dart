import 'database.dart';


class Account {

  Future<Map<String,dynamic>> getAccountInfo(int id) async {

    try {
      
      final db = await AppDatabase.database;

      final account = await db.rawQuery(
        '''

          SELECT * FROM users 
          WHERE id = ?
          LIMIT 1

        ''',[id]);

        if(account.isNotEmpty){
          return account.first;
        }else{
          return {'message': 'No account found.'};
        }

    } catch (error) {
      
      print("Unable to fetch account's data");
      throw Exception("Failed to fetch account");

    }

  }


Future<bool> updateAccount({
  required int id,
  required String name,
  required String email,
  required String contact,
  required String address,
}) async {
  try {
    final db = await AppDatabase.database;

    await db.update(
      'users',
      {
        'name': name,
        'email': email,
        'contact_number': contact,
        'address': address,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    return true;
  } catch (error) {
    print("Update failed: $error");
    return false;
  }
}

}