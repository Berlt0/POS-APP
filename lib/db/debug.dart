import 'package:pos_app/db/database.dart';

  Future<void> printTables() async {
  final db = await AppDatabase.database;

  // Print sales table
  final sales = await db.query('sales');
  print('--- SALES ---');
  for (var row in sales) {
    print(row);
  }

  // Print sale_items table
  final saleItems = await db.query('sale_items');
  print('--- SALE ITEMS ---');
  for (var row in saleItems) {
    print(row);
  }

  // Print transaction_history table
  final transactions = await db.query('transaction_history');
  print('--- TRANSACTION HISTORY ---');
  for (var row in transactions) {
    print(row);
  }
}