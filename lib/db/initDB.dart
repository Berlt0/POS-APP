import 'package:pos_app/db/database.dart';
import 'package:pos_app/db/syncUser.dart';
import 'package:pos_app/db/sync.dart';
import 'package:pos_app/db/syncTransationHistory.dart';
import 'package:sqflite/sqflite.dart'; 
import 'dart:async';




Future<bool> isDatabaseEmpty() async {
  final db = await AppDatabase.database;

  // Check if tables exist and have data
  final tables = ['users', 'products', 'sales', 'sale_items', 'transactions'];
  for (var table in tables) {
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table')
      );
      if (count != null && count > 0) {
        return false; // Found data in a table
      }
    } catch (e) {
      // Table doesn't exist yet
      return true;
    }
  }
  return true; // All tables empty or don't exist
}



Future<void> initializeDatabaseAndSync() async {
  final dbEmpty = await isDatabaseEmpty();

  if (dbEmpty) {
    print("Database is empty. Fetching initial data from server...");

    // Fetch all data from server and populate local DB
    await fetchUserFromServer();
    await getAllProducts();
    await fetchSalesFromServer();
    await fetchTransactionRecordsFromDB();

    await syncAllDataOnAuto();

    print("Initial data loaded and synced.");
  } else {
    print("Database already has data. Starting auto-sync only.");
  }

  // Start auto-sync timer every 60 sec
  Timer.periodic(Duration(seconds: 60), (timer) {
    syncAllDataOnAuto();
  });
}