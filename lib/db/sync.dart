import 'package:pos_app/db/syncUser.dart';
import 'package:pos_app/models/products.dart';
import 'package:pos_app/utils/network.dart';
import 'dart:async';
import 'database.dart';
import '../services/api_service.dart';
import '../db/product.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pos_app/db/syncTransationHistory.dart';
import 'package:sqflite/sqflite.dart';

Future<List<Map<String, dynamic>>> getUnsyncedProducts() async {
  final db = await AppDatabase.database;

  final List<Map<String, dynamic>> unsyncedProducts = await db.query(
    'products',
    where: 'is_synced = ?',
    whereArgs: [0],
  );

  return unsyncedProducts;
}



Future<List<Map<String,dynamic>>> getUnsyncedSales() async{

  final db = await AppDatabase.database;

   final sales = await db.query(
    'sales',
    where: 'is_synced = ?',
    whereArgs: [0],
  );

  List<Map<String, dynamic>> result = [];

  for (var sale in sales) {
    final items = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [sale['id']],
    );

    result.add({
      ...sale,
      'items': items,
    });
  }
  return result;
}



Future<List<Map<String, dynamic>>> getUnsyncedArchives() async {
  final db = await AppDatabase.database;

  final List<Map<String, dynamic>> unsyncedArchives = await db.query(
    'products_archive',
    where: 'is_synced = ?',
    whereArgs: [0],
  );

  return unsyncedArchives;
  
}


Future<void> markProductAsSynced(int productId) async {
  final db = await AppDatabase.database;

  await db.update(
    'products',
    {
      'is_synced': 1,  
    },
    where: 'id = ?',
    whereArgs: [productId],
  );
}



Future<void> softDeleteProduct(int productId) async {
  final db = await AppDatabase.database;

  await db.update(
    'products',
    {
      'deleted_at': DateTime.now().toIso8601String(), 
      'is_synced': 0,  
      'updated_at': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [productId],
  );
}



Future<void> updateProductSync(Map<String,dynamic> updatedData, int productId) async {
  
    final db = await AppDatabase.database;

    await db.update(
      'products',
      {
        ...updatedData,
        'is_synced': 0,
        'updated_at': DateTime.now().toIso8601String(),  
      },
      where: 'id = ?',
      whereArgs: [productId],
    );  

}



Future<List<Product>> getAllProducts() async {
  

  print('--------------------------------------------------------------------');

  if(await hasInternet()){

    print("Fetching from server...");

    try {

      final db = await AppDatabase.database;
      final serverProducts = await ApiService.get('/sync/products');

      for(var p in serverProducts){

        final product = Product.fromMap(p);
        product.isSync = 1;

        await db.insert('products', product.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);

      }
      print('Successfully fetched products data in server');
      return serverProducts.map((p) => Product.fromMap(p)).toList();

    } catch (error) {

      print('Failed to fetch products from the server: $error');
      return [];
      
    }
  } 

  return await ProductDB.getAllActiveProducts();
}



Future<List<Map<String, dynamic>>> getUnsyncedUsers() async {
  final db = await AppDatabase.database;

  final List<Map<String, dynamic>> unsyncedUsers = await db.query(
    'users',
    where: 'is_synced = ?',
    whereArgs: [0],
  );

  return unsyncedUsers;
}



Future<void> markUserAsSynced(int userId) async {
  final db = await AppDatabase.database;

  await db.update(
    'users',
    {'is_synced': 1},
    where: 'id = ?',
    whereArgs: [userId],
  );
}



Future<void> syncUsers() async {
  
    if (!(await hasInternet())) return;

    final users = await getUnsyncedUsers();
    for (var user in users) {
      try {

        final res = await ApiService.post('/sync/users', user);

        if (res.statusCode == 200) {
          await markUserAsSynced(user['id']);
          print("User ${user['id']} synced");
        } else {
          print("Failed to sync user ${user['id']}: ${res.statusCode}");
        }
      } catch (e) {
        print("Error syncing user ${user['id']}: $e");
      }
    }
 
}



Future<void> syncProducts() async {


    if(!(await hasInternet())){
      print('No internet. Skipping sync');
      return;
    }

  try{

    final products = await getUnsyncedProducts();
    
    for(var product in products){
      print(product);

      try{

        final res = await ApiService.post('/sync/products', product);

        if(res.statusCode == 200){
          await markProductAsSynced(product['id']);

        }else{
          print("Failed to sync product ${product['id']}: ${res.statusCode}");
        }
      }catch(error){

        print("Error fetching unsynced products: $error");
      
      }
    }

  }
  catch(error){

    print("Error syncing products: $error");
  
  }

}



Future<void> syncSales() async {

 


  if (!(await hasInternet())) {
    print("No internet");
    return;
  }

  final db = await AppDatabase.database;
  final sales = await getUnsyncedSales();


  for (var sale in sales) {
    try {
      final res = await ApiService.post('/sync/sales', sale);
      

      if (res.statusCode == 200) {

        await db.update(
          'sales',
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [sale['id']],
        );

        await db.update(
          'sale_items',
          {'is_synced': 1},
          where: 'sale_id = ?',
          whereArgs: [sale['id']],
        );


        print("Sale ${sale['id']} synced");

      } else {
        print("Failed syncing sale ${sale['id']}");
      }

    } catch (e) {
      print("Error syncing sale ${sale['id']}: $e");
    }
  }


}



// Future<void> fetchSalesFromServer() async {

//   if (!(await hasInternet())) return;

//   try {
    
//     final db = await AppDatabase.database;

//     print("Fetching sales from server");

//     final serverSales = await ApiService.get('/sync/sales');

//     for (var sale in serverSales){

//       await db.insert('sales', {

//         'id': sale['id'],
//         'user_id': sale['user_id'],
//         'total_amount': sale['total_amount'],
//         'amount_received': sale['amount_received'],
//         'change_amount': sale['change_amount'],
//         'payment_type': sale['payment_type'],
//         'created_at': sale['created_at'],
//         'is_synced': 1,

//       },
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );

//       final items = sale['items'] as List;

//       for(var item in items){

//         await db.insert('sale_items', {
//            'id': item['id'],
//             'sale_id': item['sale_id'],
//             'product_id': item['product_id'],
//             'product_name': item['product_name'],
//             'price': item['price'],
//             'quantity': item['quantity'],
//             'created_at': item['created_at'],
//             'is_synced': 1,
//         },
//         conflictAlgorithm: ConflictAlgorithm.replace
//         );
//       }
//     }

//     print("Sales synced from server to local DB");

//   } catch (error) {
    
//     print("Error fetching sales $error");

//   }
// }


Future<void> fetchSalesFromServer() async {
  if (!(await hasInternet())) return;

  try {
    final db = await AppDatabase.database;

    print("Fetching sales from server");

    final serverSales = await ApiService.get('/sync/sales');

    for (var sale in serverSales){

    
      final existingSale = await db.query(
        'sales',
        where: 'id = ?',
        whereArgs: [sale['id']],
      );

      if (existingSale.isEmpty) {
      
        await db.insert('sales', {
          'id': sale['id'],
          'user_id': sale['user_id'],
          'total_amount': sale['total_amount'],
          'amount_received': sale['amount_received'],
          'change_amount': sale['change_amount'],
          'payment_type': sale['payment_type'],
          'created_at': DateTime.parse(sale['created_at']).toLocal().toIso8601String(),
          'is_synced': 1,
        });
      }

      // 🔧 SAME FIX FOR sale_items
      final items = sale['items'] as List;

      for(var item in items){

        final existingItem = await db.query(
          'sale_items',
          where: 'id = ?',
          whereArgs: [item['id']],
        );

        if (existingItem.isEmpty) {
          await db.insert('sale_items', {
            'id': item['id'],
            'sale_id': item['sale_id'],
            'product_id': item['product_id'],
            'product_name': item['product_name'],
            'price': item['price'],
            'quantity': item['quantity'],
            'created_at': DateTime.parse(item['created_at']).toLocal().toIso8601String(),
            'is_synced': 1,
          });
        }
      }
    }

    print("Sales synced from server to local DB");

  } catch (error) {
    print("Error fetching sales $error");
  }
}


Future<void> syncArchives() async {
  if (!(await hasInternet())) {
    print("No internet");
    return;
  }

  final db = await AppDatabase.database;
  final archives = await getUnsyncedArchives();

  final archivedProducts = await db.query(
    'products_archive',
    where: 'is_synced = ?',
    whereArgs: [0],
  );


  final serverProducts = await ApiService.get('/sync/products'); 
  final serverIds = serverProducts.map((p) => p['id'] as int).toSet();

  print('---------------Server product IDs: $serverIds');
  print('---------------Datatype: ${serverIds.runtimeType}');

  for (var archive in archivedProducts) {

    final id = archive['id'] as int;
    
    print('*******************id: $id');
    print('*******************Datatype: ${id.runtimeType}');

    if (serverIds.contains(id)) {
      try {
        final res = await ApiService.delete('/sync/products/$id');
        if (res.statusCode == 200) 
        print('Deleted product $id on server');
      } catch (e) {
        print('Failed to delete product $id on server: $e');
      }
    }
}


  for(var archive in archives){
    try {
      final res = await ApiService.post('/sync/archives', archive);

      if(res.statusCode == 200){
        await db.update(
          'products_archive',
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [archive['id']],
        );
        print("Archive ${archive['id']} synced");
      }else{
        print("Failed syncing archive ${archive['id']}");
      }
    } catch (error) {
      print("Error syncing product archive ${archive['id']}: $error");
    }
  }
}




Future<void> syncAllDataOnAuto() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  
  
  try{

    if (connectivityResult != ConnectivityResult.none) {
      print("Internet available, syncing unsynced data...");

      try { await syncUsers(); } catch(e){ print('Sync users failed: $e'); }
      try { await syncProducts(); } catch(e){ print('Sync products failed: $e'); }
      try { await syncSales(); } catch(e){ print('Sync sales failed: $e'); }
      try { await syncTransaction(); } catch(e){ print('Sync transactions failed: $e'); }
      try { await syncArchives(); } catch(e){ print('Sync archives failed: $e'); }

      // Pull fresh data
      try { await fetchUserFromServer(); } catch(e){ print('Fetch users failed: $e'); }
      try { await getAllProducts(); } catch(e){ print('Fetch products failed: $e'); }
      try { await fetchSalesFromServer(); } catch(e){ print('Fetch sales failed: $e'); }
      try { await fetchTransactionRecordsFromDB(); } catch(e){ print('Fetch transactions failed: $e'); }

      print("Sync completed.");
    } else {
      print("No internet. Will sync when connection is available.");
    }


  }catch(error){
    print('Syncing failed. Error');
  }

}

