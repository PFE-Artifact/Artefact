import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:artefacts/main.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the localizations
    final localizations = AppLocalizations.of(context)!;
    // Get the locale provider
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              // In your language selector:
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
                  localeProvider.setLocale(Locale('ar', 'TN'));
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
      body: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image at the top
              SizedBox(
                width: 300, // Adjust width for better centering
                height: 300,
                child: Image.asset('assets/homeP.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),

              // Main Text
              Text(
                localizations.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1f41bb),
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  localizations.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Property1active(
                      text: localizations.login,
                    ),
                    const SizedBox(height: 10),
                    Property1Default(
                      text: localizations.register,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Login Button
class Property1active extends StatelessWidget {
  final String text;

  const Property1active({Key? key, this.text = 'Login'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/SignInSignUp');
      },
      child: Container(
        width: double.infinity, // Makes it stretch to full width
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xff1f41bb),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Register Button
class Property1Default extends StatelessWidget {
  final String text;

  const Property1Default({Key? key, this.text = 'Register'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/register');
      },
      child: Container(
        width: double.infinity, // Makes it stretch to full width
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}