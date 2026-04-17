import 'database.dart';
import 'package:pos_app/models/addCashier.dart';
import 'package:sqflite/sqflite.dart';



class Summary {

 Future<Map<String, dynamic>?> getLoggedInUserInfo() async {
  try {
    final db = await AppDatabase.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        se.id,
        se.user_id,
        se.username,
        se.role,
        us.name,
        us.email,
        us.contact_number,
        us.address,
        us.createdAt
      FROM session se
      LEFT JOIN users us ON us.id = se.user_id
      WHERE se.user_id IS NOT NULL
      LIMIT 1
    ''');

    print('OOOOOOOOOOO $result');

    return result.isNotEmpty ? result.first : null;

  } catch (e) {
    print("Error fetching user info: $e");
    return null;
  }
}



 Future<Map<String, dynamic>> getTodaysSummary(int userId) async {
    try {
      final db = await AppDatabase.database;


      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT
          (SELECT COUNT(*) FROM sales s
          WHERE s.user_id = ? 
            AND DATE(s.created_at) = DATE('now') 
            AND s.status IS NOT 'voided') AS transaction_count,
  
          (SELECT IFNULL(SUM(s.total_amount), 0) FROM sales s 
          WHERE s.user_id = ? 
            AND  DATE(s.created_at) = DATE('now') 
            AND s.status IS NOT 'voided' ) AS total_revenue,

          (SELECT IFNULL(SUM(si.quantity), 0) FROM sale_items si
          INNER JOIN sales s ON s.id = si.sale_id 
          WHERE s.user_id = ? 
            AND  DATE(s.created_at) = DATE('now') 
            AND s.status IS NOT 'voided' ) AS items_sold

        
      ''', [userId, userId, userId]);

      final data = result.first;

      final transactionCount = data['transaction_count'];
      final totalRevenue = data['total_revenue'] as num;
      final itemsSold = data['items_sold'] ?? 0;

      final averageSales =
          transactionCount > 0 ? totalRevenue / transactionCount : 0.00;

      return {
        'transaction_count': transactionCount,
        'total_revenue': totalRevenue,
        'items_sold': itemsSold,
        'average_sales': averageSales,
      };
    } catch (e) {
      print("Error fetching today's summary: $e");
      return {
        'transaction_count': 0,
        'total_revenue': 0.0,
        'items_sold': 0,
        'average_sales': 0.0,
      };
    }
  }


  Future<List<Map<String, dynamic>>> allCashier() async {
  try {
    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT 
        u.id,
        u.username,
        u.name,

       
        COUNT(DISTINCT s.id) AS transaction_count,

  
        IFNULL(SUM(s.total_amount), 0) AS total_revenue,

       
        IFNULL(SUM(si.quantity), 0) AS items_sold,

      
        CASE 
          WHEN COUNT(DISTINCT s.id) > 0 
          THEN SUM(s.total_amount) / COUNT(s.id)
          ELSE 0
        END AS average_sales

      FROM users u

      LEFT JOIN sales s 
        ON s.user_id = u.id 
        AND DATE(s.created_at) = DATE('now')
        AND s.status != 'voided'

      LEFT JOIN sale_items si 
        ON si.sale_id = s.id

      WHERE u.role = ?
      AND u.deleted_at IS NULL

      GROUP BY u.id
    ''', ['cashier']);

    return result;
  } catch (error) {
    print("Error fetching cashier summary: $error");
    return [];
  }
}


Future<int> insertCashier(Addcashier cashier) async {
  try {
    final db = await AppDatabase.database;

    final id = await db.insert(
      'users',
      cashier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    print("Cashier inserted with ID: $id");
    return id;
  } catch (e) {
    print("Error inserting cashier: $e");
    throw Exception("Failed to add cashier");
  }
}

}
 
