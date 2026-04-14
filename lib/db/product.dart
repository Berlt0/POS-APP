
import 'package:sqflite/sqflite.dart';
import '../models/products.dart';
import 'database.dart';


class ProductDB {


  static Future<int> insert(Product product) async {
    final db = await AppDatabase.database;
    return await db.insert('products', product.toMap());
  }



  static Future<List<Product>> getAllActiveProducts() async {

    final db = await AppDatabase.database;
    final result = await db.query(
      'products',
      where: 'deleted_at IS NULL',
      );

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



  static Future<int> countProducts() async {

    final db = await AppDatabase.database;

    final result = await db.rawQuery('SELECT COUNT(*) FROM products WHERE deleted_at IS NULL');

    return Sqflite.firstIntValue(result) ?? 0;

  }



static Future<void> archiveProduct(int productId) async {

  final db = await AppDatabase.database;
    
  final now = DateTime.now().toIso8601String();

  await db.transaction((txn) async {
    await txn.rawInsert('''
      INSERT INTO products_archive (
        id, global_id, name, price, stock, stock_unit,cost, category, barcode, 
        low_stock_alert, description, image_path, createdAt,  
        updated_at, deleted_at, is_synced
      )
       SELECT id, global_id, name, price, stock, stock_unit,cost, category, barcode, 
        low_stock_alert, description, image_path, createdAt, 
        updated_at, ?, 0
      FROM products
      WHERE id = ?
      
      ''',[now,productId],
    );

    await txn.delete(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );

    });

  }

}


