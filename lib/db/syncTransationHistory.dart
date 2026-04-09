
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



Future<void> fetchTransactionRecordsFromDB () async {

  if(!(await hasInternet())) return;

  try{

    final db = await AppDatabase.database;

    print("Fetching transactions from server...");

    final serverTransaction = await ApiService.get('/sync/transaction');

    for(var tnx in serverTransaction){

     final existing = await db.query(
      'transaction_history',
      where: 'global_id = ?',
      whereArgs: [tnx['global_id']],
    );

    if (existing.isEmpty) {
      await db.insert('transaction_history', {
        'global_id': tnx['global_id'],
        'user_id': tnx['user_id'],
        'user_global_id': tnx['user_global_id'],
        'action': tnx['action'],
        'entity_type': tnx['entity_type'],
        'entity_id': tnx['entity_id'],
        'entity_global_id': tnx['entity_global_id'],
        'description': tnx['description'],
        'created_at': tnx['created_at'],
        'is_synced': 1,
      });
    }
    }

     print("Transactions synced from server to local DB");

  }catch(error){
    print("Error fetching transactions: $error");
  }

}