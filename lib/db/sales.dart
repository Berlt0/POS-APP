import 'package:pos_app/db/database.dart';
import 'package:sqflite/sqflite.dart';


class Sales{

  static Future<int> countTodaySales() async {

    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sales
      WHERE DATE(datetime(created_at, 'localtime')) = DATE('now', 'localtime') AND status IS NOT 'voided'
    ''');

    return Sqflite.firstIntValue(result) ?? 0;

  }



  static Future<double> todaysRevenue() async {

    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total FROM sales
      WHERE DATE(datetime(created_at, 'localtime')) = DATE('now', 'localtime') AND status IS NOT 'voided'
    ''');

    return result.first['total'] != null ? (result.first['total'] as num).toDouble() : 0.0;
  }



  static Future<List<Map<String, dynamic>>> fetchRecentSales() async{

    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT 
        s.id,
        s.total_amount,
        s.created_at,
        si.product_name,
        si.quantity,
        si.price
      FROM sales s
      JOIN sale_items si ON si.sale_id = s.id
      WHERE s.status IS NOT 'voided'
      ORDER BY s.created_at DESC
      LIMIT 10;
    ''');   // GROUP BY s.id

    return result;

  }



  static Future<List<Map<String, dynamic>>> fetchWeeklySales() async {
  
    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT 
        DATE(datetime(created_at, 'localtime')) AS sale_date,
        COUNT(*) AS total_sales
      FROM sales
      WHERE DATE(datetime(created_at, 'localtime')) >= DATE('now', 'localtime', '-6 days') AND status IS NOT 'voided'
      GROUP BY sale_date
      ORDER BY sale_date ASC;
    ''');

    return result;
}


}