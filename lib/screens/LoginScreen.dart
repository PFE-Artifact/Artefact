import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'AccueilScreen.dart';
import 'package:artefacts/main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginWithGoogle() async {
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print("Google sign-in was canceled.");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Navigate to AccueilScreen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccueilScreen()),
        );
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to home page after successful login
      Navigator.pushReplacementNamed(context, "/accueil");
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "An error occurred";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the localizations
    final localizations = AppLocalizations.of(context)!;
    // Get the locale provider to check current language
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isRTL = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      localeProvider.locale.languageCode == 'en'
                          ? '🇬🇧'
                          : '🇹🇳',
                      style: TextStyle(fontSize: 24)
                  ),
                  Icon(Icons.arrow_drop_down, color: Color(0xff1f41bb)),
                ],
              ),
              onSelected: (String languageCode) {
                if (languageCode == 'en') {
                  localeProvider.setLocale(Locale('en'));
                } else {
                  localeProvider.setLocale(Locale('ar'));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'en',
                  child: Row(
                    children: [
                      Text('🇬🇧', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 10),
                      Text('English'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'ar',
                  child: Row(
                    children: [
                      Text('🇹🇳', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 10),
                      Text('تونسي'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.loginHere,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1f41bb),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  localizations.welcomeBack,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Image.asset(
                    "assets/Login.png",
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 30),

                // Email Field
                _buildTextField(_emailController, localizations.email, false),
                const SizedBox(height: 20),

                // Password Field
                _buildTextField(_passwordController, localizations.password, true),

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    ),
                  ),

                const SizedBox(height: 15),

                Align(
                  alignment: isRTL ? Alignment.centerLeft : Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      localizations.forgotPassword,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff1f41bb),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1f41bb),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    localizations.login,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Text(
                    localizations.orContinueWith,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff1f41bb),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await loginWithGoogle();
                      },
                      icon: _socialMediaButton("assets/google.png"),
                    ),
                    const SizedBox(width: 15),
                    _socialMediaButton("assets/fb.png"),
                  ],
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      localizations.dontHaveAccount,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: Text(
                        localizations.signUp,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff1f41bb),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom TextField Widget
  Widget _buildTextField(TextEditingController controller, String hintText, bool isPassword) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isRTL = localeProvider.locale.languageCode == 'ar';

    return TextField(
      controller: controller,
      obscureText: isPassword,
      textAlign: isRTL ? TextAlign.right : TextAlign.left,
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        hintText: hintText,
        hintTextDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        filled: true,
        fillColor: const Color(0xfff1f4ff),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xff1f41bb), width: 2),
        ),
      ),
    );
  }

  // Social Media Button
  Widget _socialMediaButton(String assetPath) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xffececec),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}