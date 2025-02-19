
import 'package:flutter/material.dart';
import 'package:artefacts/screens/HomePage.dart';
import 'package:artefacts/screens/LoginScreen.dart';
import 'package:artefacts/screens/RegisterScreen.dart';
import 'package:artefacts/screens/AccueilScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/accueil': (context) => AccueilScreen(),

      },
    );
  }
}
