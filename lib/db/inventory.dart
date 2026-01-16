import '../models/products.dart';
import 'database.dart';

class InventoryDB {


// Fetch just for the product id,name,category,stock,low_stock_alert,price,cost,imagePath 

static Future<List<SomeProductData>> getFewProductsData({
  required int page,
  required int limit,
  String? category,   // optional category filter
  String? searchText, // optional search filter
}) async {
  final db = await AppDatabase.database;
  final offset = (page - 1) * limit;

  String where = '';
  List<dynamic> whereArgs = [];

  if (category != null && category != 'All') {
    where = 'category = ?';
    whereArgs.add(category);
  }

  if (searchText != null && searchText.isNotEmpty) {
    if (where.isNotEmpty) where += ' AND ';
    where += 'name LIKE ?';
    whereArgs.add('%$searchText%');
  }

  final result = await db.query(
    'products',
    columns: ['id','name','category','stock','low_stock_alert','image_path'],
    where: where.isNotEmpty ? where : null,
    whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    limit: limit,
    offset: offset,
    orderBy: 'name ASC',
  );

  return result.map((product) => SomeProductData.fromMap(product)).toList();
}



static Future<int> countProductsFiltered({String? category, String? searchText}) async {
  final db = await AppDatabase.database;

  String where = '';
  List<dynamic> whereArgs = [];

  if (category != null && category != 'All') {
    where = 'category = ?';
    whereArgs.add(category);
  }

  if (searchText != null && searchText.isNotEmpty) {
    if (where.isNotEmpty) where += ' AND ';
    where += 'name LIKE ?';
    whereArgs.add('%$searchText%');
  }

  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM products ${where.isNotEmpty ? 'WHERE $where' : ''}',
    whereArgs,
  );

  return result.first['count'] as int;
}



  //Get products category

  static Future<List<String>> getCategories() async {
  final db = await AppDatabase.database;

  final result = await db.rawQuery(
    'SELECT DISTINCT category FROM products'
  );

  return result.map((e) => e['category'] as String).toList();
}


}
