import 'package:sqflite/sqflite.dart';
import '../models/products.dart';
import 'database.dart';


class ProductDB {


  static Future<int> insert(Product product) async {
    final db = await AppDatabase.database;
    return await db.insert('products', product.toMap());
  }

// Fetch all Product/s Data
  static Future<List<Product>> getAll() async {
    final db = await AppDatabase.database;
    final result = await db.query('products');

    return result.map((e) => Product.fromMap(e)).toList();
  }


// Update product stock 

  static Future<void> updateStock(int id, int stock) async {
    final db = await AppDatabase.database;
    await db.update(
      'products',
      {'stock': stock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }


static Future<int> updateProduct(editProduct product) async {
  final db = await AppDatabase.database;

  return await db.update(
    'products',
    product.toMap(),
    where: 'id = ?',
    whereArgs: [product.id],
  );
}





  static Future<void> delete(int id) async {
    final db = await AppDatabase.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }



  static Future<int> countProducts() async {

    final db = await AppDatabase.database;

    final result = await db.rawQuery('SELECT COUNT(*) FROM products');

    return Sqflite.firstIntValue(result) ?? 0;

  }

}


