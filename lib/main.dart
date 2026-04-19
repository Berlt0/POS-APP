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
import 'package:provider/provider.dart';
import 'providers/theme.provider.dart';


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
  
  final bool loggedIn = await isUserLoggedIn();

  debugPrint('Is user logged in? $loggedIn');

  await initializeDatabaseAndSync();

  if (loggedIn) {
    final session = await SessionService.getSession();
    print(session);
    print('--- Logged-in user data ---');
    print('User ID: ${session?['user_id']}');
    print('Username: ${session?['username']}');
    print('Role: ${session?['role']}');
  }


  runApp(
  ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: MyApp(isLoggedIn: loggedIn),
  ),
);

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
    
    final themeProvider = Provider.of<ThemeProvider>(context);


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        dividerColor: Colors.black87, 
        
      ),

      darkTheme: ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      dividerColor: Colors.black87, 

      colorScheme: const ColorScheme.dark(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Color.fromARGB(209, 49, 49, 49),
        background: Color(0xFF121212),
        
      ),

      appBarTheme:  AppBarTheme(
        backgroundColor:Color.fromARGB(209, 49, 49, 49),
        foregroundColor: Colors.grey[100],
        elevation: 0,
        scrolledUnderElevation: 0, 
        surfaceTintColor: Colors.transparent, 
      ),

      cardColor: const Color(0xFF1E1E1E),

      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        border: OutlineInputBorder(),
        labelStyle: TextStyle(color: Colors.white70),
      ),
    ),

      themeMode: themeProvider.themeMode,

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
        '/settings': (context) => const Settings()
      },
    );
  }
}
