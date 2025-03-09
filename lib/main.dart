import 'package:artefacts/screens/ProfileScreen.dart';
import 'package:artefacts/screens/QuizT1H/BeginnerT1H.dart';
import 'package:artefacts/screens/QuizT1H/Level1T_H.dart';
import 'package:artefacts/screens/Quizz.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:artefacts/screens/HomePage.dart';
import 'package:artefacts/screens/LoginScreen.dart';
import 'package:artefacts/screens/RegisterScreen.dart';
import 'package:artefacts/screens/AccueilScreen.dart';
import 'screens/question_screen.dart';
import 'screens/map_screen.dart';
import 'screens/model/game_state.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tunisia History Game',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/accueil': (context) => AccueilScreen(),
        '/quizz': (context) => Quizz(),
        '/Level1T_H': (context) => Level1T_H(),
        '/BeginnerT1H': (context) => BeginnerT1H(),
        '/map': (context) => const MapScreen(),
        '/questions': (context) => const QuestionScreen(levelId: 1,),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
