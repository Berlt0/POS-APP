import 'package:pos_app/db/database.dart';

  Future<void> printTables() async {
  final db = await AppDatabase.database;

print('----------Users----------');

  // Print sales table
  final users = await db.query('users');
  print('--- users ---');
  for (var row in users) {
    print(row);
  }

  print('----------Products----------');

  // Print sales table
  final products = await db.query('products');
  for (var row in products) {
    print(row);
  }


print('----------Sales----------');

  // Print sales table
  final sales = await db.query('sales');
  print('--- SALES ---');
  for (var row in sales) {
    print(row);
  }

  print('----------Sales Items----------');

  // Print sale_items table
  final saleItems = await db.query('sale_items');
  print('--- SALE ITEMS ---');
  for (var row in saleItems) {
    print(row);
  }

  print('----------Transaction History End----------');


  final transactions = await db.query('transaction_history');
  print('--- TRANSACTION HISTORY ---');
  for (var row in transactions) {
    print(row);
  }

  print('----------Products Archive----------');

  final archives = await db.query('products_archive');
  print('--- PRODUCTS ARCHIVE ---');
  for (var row in archives) {
    print(row);
  }

  print('----------Store Info----------');

  final store = await db.query('store_info');
  print('--- Store Info ---');
  for (var row in store) {
    print(row);
  }

   print('----------Session----------');

  final session = await db.query('session');
  print('--- Session ---');
  for (var row in session) {
    print(row);
  }


}