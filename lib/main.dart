import 'package:flutter/material.dart';
import 'package:pos_app/db/initDB.dart';
import 'package:pos_app/pages/settings/settings.dart';
import 'package:pos_app/pages/addproduct.dart';
import 'package:pos_app/pages/home.dart';
import 'package:pos_app/pages/inventory.dart';
import 'package:pos_app/pages/login.dart';
import 'package:pos_app/pages/products.dart';
import 'package:pos_app/pages/reports.dart';
import 'package:pos_app/pages/pos.dart';
import 'db/database.dart';
import 'db/addUser.dart';
import 'services/auth_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pos_app/pages/reviewCart.dart';
import 'package:pos_app/pages/profile.dart';
import 'package:pos_app/services/session_service.dart';
import 'pages/receipt.dart';
import 'pages/transaction.dart';
import 'dart:async';


Future<void> deleteOldDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'pos.db');
  await deleteDatabase(path);
  print("Old database deleted");
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  // await deleteOldDatabase();


  await AppDatabase.database;


  await UserSeed.seed();


  // call isLoggedIn() defensively
  final dynamic result = await AuthService.isLoggedIn(); 
  final bool loggedIn = await isUserLoggedIn();

  debugPrint('Is user logged in? $loggedIn');

  if (loggedIn) {
    final session = await SessionService.getSession();
    print(session);
    print('--- Logged-in user data ---');
    print('User ID: ${session?['user_id']}');
    print('Username: ${session?['username']}');
    print('Role: ${session?['role']}');
  }


  runApp(MyApp(isLoggedIn: loggedIn));

  
    await initializeDatabaseAndSync();
  
}

Future<bool> isUserLoggedIn() async {
  final bool tokenExists = await AuthService.isLoggedIn();
  final sessionExists = await SessionService.getSession() != null;
  return tokenExists && sessionExists;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const Home(),
        '/inventory': (content) => const Inventory(),
        '/products': (context) => const Products(),
        '/reports': (context) => const Reports(),
        '/pos': (context) => const POS(),
        '/addproduct': (context) => const Addproduct(),
        '/reviewcart': (context) => const ReviewCart(),
        '/receipt': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

           if (args == null) {
            return const Scaffold(
              body: Center(child: Text('No transaction data provided')),
            );
          }

          return ViewReceipt(transaction: args);
        },  
        '/transaction': (context) => const TransactionPage(),
        '/profile': (context) => const ProfilePage(),
        '/settins': (context) => const Settings()
      },
    );
  }
}
