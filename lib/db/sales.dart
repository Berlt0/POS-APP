import 'package:pos_app/db/database.dart';
import 'package:sqflite/sqflite.dart';


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

}