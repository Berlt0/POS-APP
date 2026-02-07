import 'package:flutter/material.dart';
import 'package:pos_app/db/database.dart';
import 'package:intl/intl.dart';


Future<Map<String,dynamic>> fetchReportCard({
  required String filter,
  DateTimeRange? dateRange
}) async {

  String range = '';
  List<dynamic> args = [];

  final db = await AppDatabase.database;

  if (filter == 'Today') {
    range = "DATE(s.created_at) = DATE('now')";
  } 
  else if (filter == 'Weekly') {
    range = "s.created_at >= DATE('now', '-6 days')";
  } 
  else if (filter == 'Custom' && dateRange != null) {
    range = "DATE(s.created_at) BETWEEN ? AND ?";
    args = [
        DateFormat('yyyy-MM-dd').format(dateRange.start),
        DateFormat('yyyy-MM-dd').format(dateRange.end),
      ];
    }

  final result = await db.rawQuery('''
    SELECT
      COUNT(DISTINCT s.id) AS total_sales,
      IFNULL(SUM(s.total_amount), 0) AS revenue,
      IFNULL(SUM(si.quantity * p.cost), 0) AS cogs
    FROM sales s
    JOIN sale_items si ON si.sale_id = s.id
    JOIN products p ON p.id = si.product_id
    WHERE $range
  ''', args);

  final row = result.first;

  final revenue = (row['revenue'] as num).toDouble();
  final cogs = (row['cogs'] as num).toDouble();
  final profit = revenue - cogs;
  
   return {
    'totalSales': row['total_sales'],
    'revenue': revenue,
    'profit': profit,
    'margin': revenue == 0 ? 0 : (profit / revenue) * 100,
  };



}