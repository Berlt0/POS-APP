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

// Fetch just for the product id,name,category,stock,low_stock_alert,price,cost,imagePath 

  static Future<List<SomeProductData>> getFewProductsData() async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'products',
      columns: ['id','name','category','stock','low_stock_alert','price','cost','image_path']
    );

    return result.map((product) => SomeProductData.fromMap(product)).toList();

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

  static Future<void> delete(int id) async {
    final db = await AppDatabase.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
