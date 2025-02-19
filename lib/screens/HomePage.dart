import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image at the top
            Container(
              width: 400, // Adjust width as needed
              height: 400,
              child: Image.asset('assets/homeP.png', fit: BoxFit.cover),
            ),
            SizedBox(height: 20),

            // Main Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20), // Prevents overflow
              child: Text(
                "Discover Your Dream Job Here",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1f41bb),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Subtitle Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Explore all the existing job roles based on your interest and study major.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 30),

            // Buttons (Fixing Overflow)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Property1active()),
                  SizedBox(width: 10),
                  Expanded(child: Property1Default()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Login Button
class Property1active extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/login'); // Navigate to the login page
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Color(0xff1f41bb),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Login',
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

//register
class Property1Default extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/register');
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(
            'Register',
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
