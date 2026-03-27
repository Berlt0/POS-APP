import 'package:pos_app/db/database.dart';
import 'package:pos_app/db/syncUser.dart';
import 'package:pos_app/db/sync.dart';
import 'package:pos_app/db/syncTransationHistory.dart';
import 'package:sqflite/sqflite.dart'; 
import 'dart:async';




Future<bool> isDatabaseEmpty() async {
  final db = await AppDatabase.database;


  final tables = ['users', 'products', 'sales', 'sale_items', 'transactions'];
  for (var table in tables) {
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table')
      );
      if (count != null && count > 0) {
        return false; 
      }
    } catch (e) {
      
      return true;
    }
  }
  return true; 
}



Future<void> initializeDatabaseAndSync() async {
  final dbEmpty = await isDatabaseEmpty();

  if (dbEmpty) {
    print("Database is empty. Fetching initial data from server...");

   
    await fetchUserFromServer();
    await getAllProducts();
    await fetchSalesFromServer();
    await fetchTransactionRecordsFromDB();

    await syncAllDataOnAuto();

    print("Initial data loaded and synced.");
  } else {
    print("Database already has data. Starting auto-sync only.");
  }

  
  Timer.periodic(Duration(seconds: 60), (timer) {
    syncAllDataOnAuto();
  });
}