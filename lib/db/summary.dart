import 'database.dart';
import 'package:intl/intl.dart';



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

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());


      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT
          (SELECT COUNT(*) FROM sales WHERE user_id = ? AND DATE(created_at) = DATE('now') AND status IS NOT 'voided') AS transaction_count,
  
          (SELECT IFNULL(SUM(total_amount), 0) FROM sales WHERE user_id = ? AND DATE('now') AND status IS NOT 'voided' ) AS total_revenue,

          (SELECT IFNULL(SUM(si.quantity), 0) FROM sale_items si INNER JOIN sales s ON s.id = si.sale_id WHERE user_id = ? AND DATE('now') AND status IS NOT 'voided' ) AS items_sold

        
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



}
 
