import 'package:pos_app/db/database.dart';
import 'package:intl/intl.dart';


Future<List<Map<String, dynamic>>> fetchTransactions({
  DateTime? startDate,
  DateTime? endDate,
}) async {
    final db = await AppDatabase.database;

    String query = '''
      SELECT 
        t.id AS transaction_id,
        t.user_id,
        t.action,
        t.entity_id,
        t.entity_type,
        t.description,
        t.created_at,

        s.total_amount,
        s.payment_type,
        s.amount_received,
        s.change_amount,

        si.product_name,
        si.price,
        si.quantity

      FROM transaction_history t
      LEFT JOIN sales s 
        ON s.id = t.entity_id
      LEFT JOIN sale_items si
        ON si.sale_id = s.id
      

      
    ''';
    
     List<dynamic> args = [];

     if (startDate != null && endDate != null) {
      query += " WHERE DATE(t.created_at) BETWEEN ? AND ?";
      args.add(DateFormat('yyyy-MM-dd').format(startDate));
      args.add(DateFormat('yyyy-MM-dd').format(endDate));
    }

    query += " ORDER BY t.created_at DESC";

    final result = await db.rawQuery(query, args);

    return result;
  }