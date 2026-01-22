import 'database.dart';
import 'package:pos_app/models/pos.dart';

class POSDB {

  static Future<List<POSModel>> getProducts() async{

    final db = await AppDatabase.database;

    final result = await db.query('products',
    columns: ['id','name','category','price','cost','stock','image_path']);

    return result.map((row) => POSModel.fromMap(row)).toList();



  }
}