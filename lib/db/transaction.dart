import 'package:pos_app/db/database.dart';


Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT 
        t.id,
        t.total_amount,
        t.created_at,
        ti.product_name,
        ti.quantity,
        ti.price
      FROM transactions t
      JOIN transaction_items ti ON ti.transaction_id = t.id
      GROUP BY t.id
      ORDER BY t.created_at DESC
    ''');

    return result;
  }