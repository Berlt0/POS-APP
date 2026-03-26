import 'package:pos_app/db/sync.dart';
import 'package:sqflite/sqflite.dart';
import '../models/products.dart';
import 'database.dart';


class ProductDB {


  static Future<int> insert(Product product) async {
    final db = await AppDatabase.database;
    return await db.insert('products', product.toMap());
  }



  static Future<List<Product>> getAll() async {
    final db = await AppDatabase.database;
    final result = await db.query('products');

    return result.map((e) => Product.fromMap(e)).toList();
  }


  static Future<int> updateStock(int id, int stock) async {
    final db = await AppDatabase.database;
    

    final updatedStock = {
      'stock':stock,
      'is_synced':0,
      'updated_at': DateTime.now().toIso8601String()
    };

    return await db.update(
      'products',
      updatedStock, 
      where: 'id = ?',
      whereArgs: [id],
    );
  }


static Future<int> updateProduct(editProduct product) async {
  final db = await AppDatabase.database;

  final updatedProducts = {
    ...product.toMap(),
    'is_synced':0,
    'updated_at': DateTime.now().toIso8601String()
  };


  return await db.update(
    'products',
    updatedProducts,
    where: 'id = ?',
    whereArgs: [product.id],
  );
}


  static Future<void> deleteProduct(int id) async {
    final db = await AppDatabase.database;
    await db.delete(
        'products', 
      where: 'id = ?', 
      whereArgs: [id]);
  }



  static Future<int> countProducts() async {

    final db = await AppDatabase.database;

    final result = await db.rawQuery('SELECT COUNT(*) FROM products');

    return Sqflite.firstIntValue(result) ?? 0;

  }

}


