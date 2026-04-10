import 'package:pos_app/db/syncUser.dart';
import 'package:pos_app/models/products.dart';
import 'package:pos_app/utils/network.dart';
import 'dart:async';
import 'database.dart';
import '../services/api_service.dart';
import '../db/product.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pos_app/db/syncTransationHistory.dart';


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


Future<void> markProductAsSynced(String productId) async {
  final db = await AppDatabase.database;

  await db.update(
    'products',
    {
      'is_synced': 1,  
    },
    where: 'global_id = ?',
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

        // final product = Product.fromMap(p);
        // product.isSync = 1;

        final serverProduct = Product.fromMap(p).toMap();
        serverProduct['is_synced'] = 1;

        final local = await db.query(
          'products',
          where: 'global_id = ?',
          whereArgs: [serverProduct['global_id']],
        );

        

       if (local.isEmpty) {
          
          await db.insert('products', serverProduct);
        } else {
          final localUpdated = DateTime.parse(local[0]['updated_at'] as String);
          final serverUpdated = DateTime.parse(serverProduct['updated_at'] as String);

          if (serverUpdated.isAfter(localUpdated)) {
            await db.update(
              'products',
              serverProduct,
              where: 'global_id = ?',
              whereArgs: [serverProduct['global_id']],
            );
          }
        }

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



Future<void> markUserAsSynced(String userId) async {
  final db = await AppDatabase.database;

  await db.update(
    'users',
    {'is_synced': 1},
    where: 'global_id = ?',
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
          await markUserAsSynced(user['global_id']);
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
   
      try{

        final res = await ApiService.post('/sync/products', product);

        if(res.statusCode == 200){
          await markProductAsSynced(product['global_id']);

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

      if((sale['status'] as String?)?.toLowerCase() == 'voided'){

        final res = await ApiService.put('/sync/sales/status', {
          'global_id': sale['global_id'],
          'status': sale['status'],
          'voided_at': sale['voided_at'],
          'voided_by': sale['voided_by'],
          'reason': sale['reason'],
        });

        if (res.statusCode == 200) {
          await db.update(
            'sales',
            {'is_synced': 1},
            where: 'global_id = ?',
            whereArgs: [sale['global_id']],
          );

          print("Voided sale ${sale['id']} synced");
        } else {
          print("Failed syncing voided sale ${sale['id']}");
          print("Response: $res.body");
        }



      }else{

      final res = await ApiService.post('/sync/sales', sale);
      

      if (res.statusCode == 200) {

        await db.update(
          'sales',
          {'is_synced': 1},
          where: 'global_id = ?',
          whereArgs: [sale['global_id']],
        );

        await db.update(
          'sale_items',
          {'is_synced': 1},
          where: 'sale_global_id = ?',
          whereArgs: [sale['global_id']],
        );


        print("Sale ${sale['id']} synced");

      } else {
        print("Failed syncing sale ${sale['id']}");
      }
      }
    } catch (e) {
      print("Error syncing sale ${sale['id']}: $e");
    }
  }


}


Future<void> fetchSalesFromServer() async {
  if (!(await hasInternet())) return;

  try {
    final db = await AppDatabase.database;

    print("Fetching sales from server...");

    final serverSales = await ApiService.get('/sync/sales');

    await db.transaction((txn) async {
      for (var sale in serverSales) {


        final localUser = await txn.query(
          'users',
          where: 'global_id = ?',
          whereArgs: [sale['user_global_id']],
          limit: 1,
        );

        if (localUser.isEmpty) {
          print("User not found: ${sale['user_global_id']}");
          continue;
        }

        final localUserId = localUser.first['id'];

  
        final existingSale = await txn.query(
          'sales',
          where: 'global_id = ?',
          whereArgs: [sale['global_id']],
          limit: 1,
        );

        final serverUpdated = sale['updated_at'] != null
            ? DateTime.parse(sale['updated_at'])
            : DateTime.parse(sale['created_at']);

        Map<String, dynamic> saleData = {
          'global_id': sale['global_id'],
          'user_id': localUserId, 
          'user_global_id': sale['user_global_id'],
          'total_amount': sale['total_amount'],
          'amount_received': sale['amount_received'],
          'change_amount': sale['change_amount'],
          'status': sale['status'],
          'voided_at': sale['voided_at'],
          'voided_by': sale['voided_by'],
          'reason': sale['reason'],
          'payment_type': sale['payment_type'],
          'created_at': DateTime.parse(sale['created_at'])
              .toLocal()
              .toIso8601String(),
          'is_synced': 1,
        };

        int localSaleId;

        if (existingSale.isEmpty) {
        
          localSaleId = await txn.insert('sales', saleData);
        } else {
          final local = existingSale.first;

          final localUpdated = local['updated_at'] != null
              ? DateTime.parse(local['updated_at'].toString())
              : DateTime.fromMillisecondsSinceEpoch(0);

          if (serverUpdated.isAfter(localUpdated)) {
            await txn.update(
              'sales',
              saleData,
              where: 'global_id = ?',
              whereArgs: [sale['global_id']],
            );
          }

          localSaleId = local['id'] as int;
        }

       
        final items = sale['items'] as List;

        for (var item in items) {

          
          final localProduct = await txn.query(
            'products',
            where: 'global_id = ?',
            whereArgs: [item['product_global_id']],
            limit: 1,
          );

          final localProductId =
              localProduct.isNotEmpty ? localProduct.first['id'] : null;

          final existingItem = await txn.query(
            'sale_items',
            where: 'global_id = ?',
            whereArgs: [item['global_id']],
            limit: 1,
          );

          final serverItemUpdated = item['updated_at'] != null
              ? DateTime.parse(item['updated_at'])
              : DateTime.parse(item['created_at']);

          final itemData = {
            'global_id': item['global_id'],
            'sale_id': localSaleId, 
            'sale_global_id': item['sale_global_id'],
            'product_id': localProductId, 
            'product_global_id': item['product_global_id'],
            'product_name': item['product_name'],
            'price': item['price'],
            'quantity': item['quantity'],
            'created_at': DateTime.parse(item['created_at'])
                .toLocal()
                .toIso8601String(),
            'is_synced': 1,
          };

          if (existingItem.isEmpty) {
            await txn.insert('sale_items', itemData);
          } else {
            final localUpdated = existingItem.first['updated_at'] != null
                ? DateTime.parse(existingItem.first['updated_at'].toString())
                : DateTime.fromMillisecondsSinceEpoch(0);

            if (serverItemUpdated.isAfter(localUpdated)) {
              await txn.update(
                'sale_items',
                itemData,
                where: 'global_id = ?',
                whereArgs: [item['global_id']],
              );
            }
          }
        }
      }
    });

    print("Sales synced successfully");
  } catch (error) {
    print("Error fetching sales: $error");
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
  final serverIds = serverProducts
    .map((p) => p['global_id'] as String)
    .toSet();


  for (var archive in archivedProducts) {

    final globalId = archive['global_id'];
    

    if (serverIds.contains(archive['global_id'])) {

      try {
        final res = await ApiService.delete('/sync/products/$globalId');
        if (res.statusCode == 200) 
        print('Deleted product $globalId on server');
      } catch (e) {
        print('Failed to delete product $globalId on server: $e');
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
          where: 'global_id = ?',
          whereArgs: [archive['global_id']],
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


Future<void> fetchArchivesFromServer() async {
  if (!(await hasInternet())) return;

  try {
    final db = await AppDatabase.database;

    print("Fetching archives from server...");

    final serverArchives = await ApiService.get('/sync/archives');

    await db.transaction((txn) async {
      for (final archive in serverArchives) {
        final globalId = archive['global_id'];
        if (globalId == null) continue;

        final existing = await txn.query(
          'products_archive',
          where: 'global_id = ?',
          whereArgs: [globalId],
          limit: 1,
        );

        final createdValue = archive['createdAt'] ?? archive['created_at'];
        final updatedValue = archive['updated_at'];

        final serverUpdated = updatedValue != null
            ? DateTime.parse(updatedValue.toString())
            : DateTime.parse(createdValue.toString());

        final data = {
          'global_id': globalId,
          'name': archive['name'],
          'price': archive['price'],
          'stock': archive['stock'],
          'stock_unit': archive['stock_unit'],
          'cost': archive['cost'],
          'category': archive['category'],
          'barcode': archive['barcode'],
          'low_stock_alert': archive['low_stock_alert'],
          'description': archive['description'],
          'image_path': archive['image_path'],
          'createdAt': createdValue,
          'updated_at': updatedValue,
          'deleted_at': archive['deleted_at'],
          'is_synced': 1,
        };

        if (existing.isEmpty) {
          await txn.insert('products_archive', data);
        } else {
          final local = existing.first;

          final localUpdatedValue = local['updated_at'];
          final localUpdated = localUpdatedValue != null
              ? DateTime.parse(localUpdatedValue.toString())
              : DateTime.fromMillisecondsSinceEpoch(0);

          if (serverUpdated.isAfter(localUpdated)) {
            await txn.update(
              'products_archive',
              data,
              where: 'global_id = ?',
              whereArgs: [globalId],
            );
          }
        }
      }
    });

    print("Archives synced from server to local DB");
  } catch (error) {
    print("Error fetching archives: $error");
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
      try { await fetchArchivesFromServer(); } catch(e){ print('Fetch archives failed: $e'); }

      print("Sync completed.");
    } else {
      print("No internet. Will sync when connection is available.");
    }


  }catch(error){
    print('Syncing failed. Error');
  }

}

