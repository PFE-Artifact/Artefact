import 'package:artefacts/screens/ProfileScreen.dart';
import 'package:artefacts/screens/Quizz.dart';
import 'package:artefacts/screens/blog_detail_screen.dart';
import 'package:artefacts/screens/blog_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:artefacts/screens/HomePage.dart';
import 'package:artefacts/screens/SignInSignUp/LoginScreen.dart';
import 'package:artefacts/screens/SignInSignUp/RegisterScreen.dart';
import 'package:artefacts/screens/AccueilScreen.dart';
import 'screens/question_screen.dart';
import 'screens/map_screen.dart';
import 'screens/model/game_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:artefacts/providers/theme_provider.dart';


// Create a locale provider to manage language changes
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Create and initialize the theme provider
  final themeProviderInstance = ThemeProvider();
  await themeProviderInstance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameState()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider.value(value: themeProviderInstance),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current locale from the provider
    final localeProvider = Provider.of<LocaleProvider>(context);
    // Get the current theme from the provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tunisia History Game',

      // Add localization support
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Tunisian
      ],

      // Light theme
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFEEF1FF),
        cardColor: Colors.white,
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEEF1FF),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),

      // Dark theme
      darkTheme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),

      // Set theme mode based on provider
      themeMode: themeProvider.themeMode,

      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/SignInSignUp': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/accueil': (context) => AccueilScreen(),
        '/quizz': (context) => Quizz(),
        '/map': (context) => const MapScreen(),
        '/questions': (context) => const QuestionScreen(levelId: 1,),
        '/profile': (context) => ProfileScreenWrapper(),
        '/blog': (context) => BlogListScreen(),


        // Add blog-related routes

      },
    );
  }
}

// Wrapper to ensure ProfileScreen has access to ThemeProvider
class ProfileScreenWrapper extends StatelessWidget {
  const ProfileScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the ThemeProvider from the context
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Pass the ThemeProvider to ProfileScreen
    return ProfileScreen(themeProvider: themeProvider);
  }
}




