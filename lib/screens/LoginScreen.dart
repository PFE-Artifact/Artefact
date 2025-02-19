import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  "Login here",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1f41bb),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Welcome back, you’ve been missed!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                // Login Image
                Center(
                  child: Image.asset(
                    "assets/Login.png", // Make sure the image is in the assets folder
                    width: 300, // Adjust width as needed
                    height: 300, // Adjust height as needed
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 40),

                // Email & Password Fields
                _buildTextField("Email", false),
                const SizedBox(height: 20),
                _buildTextField("Password", true),

                const SizedBox(height: 15),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot your password?",
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1f41bb),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 30),

                // Social Media Sign-in
                const Center(
                  child: Text(
                    "Or continue with",
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
                    _socialMediaButton("assets/google_logo.png"),
                    const SizedBox(width: 15),
                    _socialMediaButton("assets/facebook_logo.png"),
                    const SizedBox(width: 15),
                    _socialMediaButton("assets/apple_logo.png"),
                  ],
                ),

                const SizedBox(height: 40),

                // Sign up option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: const Text(
                        "Sign up",
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
  Widget _buildTextField(String hintText, bool isPassword) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
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
