import 'package:pos_app/db/database.dart';

class Barcode {
  static Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
  final db = await AppDatabase.database;

  final result = await db.query(
    'products',
    where: 'barcode = ?',
    whereArgs: [barcode],
    limit: 1,
  );

  if (result.isNotEmpty) {
    return result.first;
  }
  return null;
}
}