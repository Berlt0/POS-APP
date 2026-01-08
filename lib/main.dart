import 'package:flutter/material.dart';
import 'package:pos_app/pages/home.dart';
import 'package:pos_app/pages/login.dart';
import 'db/database.dart';
import 'db/addUser.dart';
import 'services/auth_service.dart'; // ensure this matches your file name

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize DB & seed
  await AppDatabase.database;
  await UserSeed.seed();

  // call isLoggedIn() defensively
  final dynamic result = await AuthService.isLoggedIn(); // dynamic to catch null
  final bool loggedIn = result == true; // null or false -> false

  // debug print — remove later
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
      },
    );
  }
}
