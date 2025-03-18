import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'Auth.dart';
import 'package:artefacts/main.dart'; // Adjust the import path if needed

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  final Auth _auth = Auth();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await Future.delayed(Duration(seconds: 1));
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'score': 0,
        });

        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.registrationSuccessful)));

        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Registration failed")));
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff1f41bb)),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    localizations.createAccount,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1f41bb),
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    localizations.createAccountDescription,
                    textAlign: isRTL ? TextAlign.right : TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(localizations.username, false, _usernameController, (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.enterUsername;
                    }
                    return null;
                  }),
                  const SizedBox(height: 20),
                  _buildTextField(localizations.email, false, _emailController, (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return localizations.enterValidEmail;
                    }
                    return null;
                  }),
                  const SizedBox(height: 20),
                  _buildTextField(localizations.password, true, _passwordController, (value) {
                    if (value == null || value.length < 6) {
                      return localizations.passwordMinLength;
                    }
                    return null;
                  }),
                  const SizedBox(height: 20),
                  _buildTextField(localizations.confirmPassword, true, _confirmPasswordController, (value) {
                    if (value != _passwordController.text) {
                      return localizations.passwordsDoNotMatch;
                    }
                    return null;
                  }),
                  const SizedBox(height: 20),
                  _buildTextField(localizations.phoneNumber, false, _phoneController, (value) {
                    if (value == null || value.isEmpty || value.length < 8) {
                      return localizations.enterValidPhoneNumber;
                    }
                    return null;
                  }),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                        : Text(localizations.signUp, style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, bool isPassword, TextEditingController controller, String? Function(String?)? validator) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isRTL = localeProvider.locale.languageCode == 'ar';

    return TextFormField(
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
      validator: validator,
    );
  }
}