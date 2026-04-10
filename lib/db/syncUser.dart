import 'package:pos_app/utils/network.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'database.dart';
import '../services/api_service.dart';




Future<void> fetchUserFromServer () async {

  if(!(await hasInternet())) return;

  try{

  final db = await AppDatabase.database;

  print("Fetching users from server...");

  final usersServer = await ApiService.get('/sync/users');

  await db.transaction((txn) async {

    for (var user in usersServer) {
        final existing = await txn.query(
          'users',
          where: 'global_id = ?',
          whereArgs: [user['global_id']],
          limit: 1,
        );

        final data = {
          'global_id': user['global_id'],
          'username': user['username'],
          'password': user['password'],
          'role': user['role'],
          'name': user['name'],
          'email': user['email'],
          'contact_number': user['contact_number'],
          'address': user['address'],
          'createdAt': user['createdAt'],
          'is_synced': 1,
        };

        if (existing.isEmpty) {
          
          await txn.insert('users', data);
        } else {
          
          await txn.update(
            'users',
            data,
            where: 'global_id = ?',
            whereArgs: [user['global_id']],
          );
        }
      }
    });
 

    print("Users synced from server to local DB");


  }catch(error){
    print("Error fetching users: $error");
  }




}