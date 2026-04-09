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

  for (var user in usersServer) {
      await db.insert(
        'users',
        {
          'global_id':user['global_id'],
          'username': user['username'],
          'password': user['password'],
          'role': user['role'],
          'name': user['name'],
          'email': user['email'],
          'contact_number':user['contact_number'],
          'address': user['address'],
          'createdAt': user['createdAt'],
          'is_synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print("Users synced from server to local DB");


  }catch(error){
    print("Error fetching users: $error");
  }




}