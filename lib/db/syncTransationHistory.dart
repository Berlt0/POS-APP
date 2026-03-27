
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
        'id': tnx['id'],                 
        'user_id': tnx['user_id'],
        'action': tnx['action'],
        'entity_type': tnx['entity_type'],
        'entity_id': tnx['entity_id'],
        'description': tnx['description'],
        'created_at': tnx['created_at'],
        'is_synced': 1
      });

      if(res.statusCode == 200){

        await db.update('transaction_history', 
        {'is_synced': 1},
        where: 'id= ?',
        whereArgs: [tnx['id']],
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

      await db.insert('transaction_history', {
        'id': tnx['id'],
          'user_id': tnx['user_id'],
          'action': tnx['action'],
          'entity_type': tnx['entity_type'],
          'entity_id': tnx['entity_id'],
          'description': tnx['description'],
          'created_at': tnx['created_at'],
          'is_synced': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace
      
      );
    }

     print("Transactions synced from server to local DB");

  }catch(error){
    print("Error fetching transactions: $error");
  }

}