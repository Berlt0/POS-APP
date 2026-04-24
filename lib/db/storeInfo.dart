import 'database.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();
String generateId() => Uuid().v4();

class StoreInfoDB {

  static Future<void> insertStoreInfo({
    required String storeName,
    String? storePhone,
    String? storeEmail,
    String? streetAddress,
    String? city,
    String? province,
    String? zipCode,
  }) async {
    final db = await AppDatabase.database;

    await db.insert(
      'store_info',
      {
        'global_id': generateId(),
        'store_name': storeName,
        'store_phone': storePhone,
        'store_email': storeEmail,
        'street_address': streetAddress,
        'city': city,
        'province': province,
        'zip_code': zipCode,
        'is_synced':0,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }


static Future<Map<String, dynamic>?> getStoreInfo() async {
  final db = await AppDatabase.database;

  final result = await db.query(
    'store_info',
    limit: 1,
  );

  if (result.isNotEmpty) {
    return result.first;
  }
  return null;
}

  static Future<void> updateStoreInfo({
    int? id,
    required String storeName,
    String? storePhone,
    String? storeEmail,
    String? streetAddress,
    String? city,
    String? province,
    String? zipCode,
  }) async {
    final db = await AppDatabase.database;

    await db.update(
      'store_info',
      {
        'store_name': storeName,
        'store_phone': storePhone,
        'store_email': storeEmail,
        'street_address': streetAddress,
        'city': city,
        'province': province,
        'zip_code': zipCode,
        'is_synced': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id], 
    );
}


}