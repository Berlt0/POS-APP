import 'package:pos_app/db/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pos_app/models/sales.dart';


class Sales{

  static Future<int> countTodaySales() async {

    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sales
      WHERE DATE(created_at) = DATE('now', 'localtime')
    ''');

    return Sqflite.firstIntValue(result) ?? 0;

  }


  static Future<double> todaysRevenue() async {

    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total FROM sales
      WHERE DATE(created_at) = DATE('now', 'localtime')
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
      GROUP BY s.id
      ORDER BY s.created_at DESC
      LIMIT 10;
    ''');

    return result;

  }


  static Future<List<Map<String, dynamic>>> fetchWeeklySales() async {
  
    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT 
        DATE(created_at, 'localtime') AS sale_date,
        COUNT(*) AS total_sales
      FROM sales
      WHERE DATE(created_at, 'localtime') >= DATE('now', '-6 days', 'localtime')
      GROUP BY sale_date
      ORDER BY sale_date ASC;
    ''');

    return result;
}


}