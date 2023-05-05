import 'package:appcommerce/SignUp.dart';

import 'Caisse.dart';
import 'LoginPage.dart';
import 'Welcome.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => Welcome(),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUp(),
        '/Caisse': (context) => Caisse(),
      },
      initialRoute: '/',
    );
  }
}
