// import '../models/product.dart';
// import 'database.dart';

// class ProductDB {

//   static Future<int> insert(Product product) async {
//     final db = await AppDatabase.database;
//     return await db.insert('products', product.toMap());
//   }

//   static Future<List<Product>> getAll() async {
//     final db = await AppDatabase.database;
//     final result = await db.query('products');

//     return result.map((e) => Product(
//       id: e['id'] as int,
//       name: e['name'] as String,
//       price: e['price'] as double,
//       stock: e['stock'] as int,
//       category: e['category'] as String?,
//     )).toList();
//   }

//   static Future<void> updateStock(int id, int stock) async {
//     final db = await AppDatabase.database;
//     await db.update(
//       'products',
//       {'stock': stock},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   static Future<void> delete(int id) async {
//     final db = await AppDatabase.database;
//     await db.delete('products', where: 'id = ?', whereArgs: [id]);
//   }
// }
