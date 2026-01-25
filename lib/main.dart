import 'package:flutter/material.dart';
import 'package:pos_app/pages/addproduct.dart';
import 'package:pos_app/pages/home.dart';
import 'package:pos_app/pages/inventory.dart';
import 'package:pos_app/pages/login.dart';
import 'package:pos_app/pages/products.dart';
import 'package:pos_app/pages/reports.dart';
import 'package:pos_app/pages/pos.dart';
import 'db/database.dart';
import 'db/addUser.dart';
import 'services/auth_service.dart'; // ensure this matches your file name
import 'db/database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pos_app/pages/reviewCart.dart';

Future<void> deleteOldDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'pos.db');
  await deleteDatabase(path);
  print("Old database deleted");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize DB & seed

  await AppDatabase.database;
  await UserSeed.seed();

  // call isLoggedIn() defensively
  final dynamic result = await AuthService.isLoggedIn(); // dynamic to catch null
  final bool loggedIn = result == true; // null or false -> false

  debugPrint('AuthService.isLoggedIn() returned: $result');

  runApp(MyApp(isLoggedIn: loggedIn));
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
      },
    );
  }
}
