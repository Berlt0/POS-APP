
import 'package:pos_app/utils/network.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'database.dart';
import '../services/api_service.dart';



Future<List<Map<String,dynamic>>> getUnsyncTransaction  () async  {

  final db = await AppDatabase.database;

  return  await db.query(
    'transaction_history',
    where: 'is_synced = ?',
    whereArgs: [0]
  );

}



Future<void> syncTransaction () async {

  final db = await AppDatabase.database;

  final transactions = await getUnsyncTransaction();

  for(var tnx in transactions) {

    try{

      final res = await ApiService.post('/sync/transaction', {
        'global_id': tnx['global_id'],                 
        'user_id': tnx['user_id'],
        'user_global_id': tnx['user_global_id'],
        'action': tnx['action'],
        'entity_type': tnx['entity_type'],
        'entity_id': tnx['entity_id'],
        'entity_global_id': tnx['entity_global_id'],
        'description': tnx['description'],
        'created_at': tnx['created_at'],
        'is_synced': 1
      });

      if(res.statusCode == 200){

        await db.update('transaction_history', 
        {'is_synced': 1},
        where: 'global_id= ?',
        whereArgs: [tnx['global_id']],
        );
        print("Transaction ${tnx['id']} synced");
      }else{
        print("Failed to sync transaction ${tnx['id']}: ${res.statusCode}");
        
      }

    }catch(error){
      print("Error syncing transaction ${tnx['id']}: $error");

    }

  }

}



Future<void> fetchTransactionRecordsFromDB() async {
  if (!(await hasInternet())) return;

  try {
    final db = await AppDatabase.database;

    print("Fetching transactions from server...");

    final serverTransaction = await ApiService.get('/sync/transaction');

    await db.transaction((txn) async {
      for (final tnx in serverTransaction) {
        final existing = await txn.query(
          'transaction_history',
          where: 'global_id = ?',
          whereArgs: [tnx['global_id']],
          limit: 1,
        );

        final localUser = await txn.query(
          'users',
          where: 'global_id = ?',
          whereArgs: [tnx['user_global_id']],
          limit: 1,
        );

        if (localUser.isEmpty) {
          print(
            "Skipping transaction ${tnx['global_id']} because local user was not found: ${tnx['user_global_id']}",
          );
          continue;
        }

        final localSale = await txn.query(
          'sales',
          where: 'global_id = ?',
          whereArgs: [tnx['entity_global_id']],
          limit: 1,
        );

        if (localSale.isEmpty) {
          print(
            "Skipping transaction ${tnx['global_id']} because local sale was not found: ${tnx['entity_global_id']}",
          );
          continue;
        }

        final int localUserId = localUser.first['id'] as int;
        final int localSaleId = localSale.first['id'] as int;

        final data = {
          'global_id': tnx['global_id'],
          'user_id': localUserId,
          'user_global_id': tnx['user_global_id'],
          'action': tnx['action'],
          'entity_type': tnx['entity_type'],
          'entity_id': localSaleId, 
          'entity_global_id': tnx['entity_global_id'],
          'description': tnx['description'],
          'created_at': tnx['created_at'],
          'is_synced': 1,
        };

        if (existing.isEmpty) {
          await txn.insert('transaction_history', data);
        } else {
          await txn.update(
            'transaction_history',
            data,
            where: 'global_id = ?',
            whereArgs: [tnx['global_id']],
          );
        }
      }
    });

    print("Transactions synced from server to local DB");
  } catch (error) {
    print("Error fetching transactions: $error");
  }
}