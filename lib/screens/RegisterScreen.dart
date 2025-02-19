import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Title
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1f41bb),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Create an account so you can explore all the existing jobs",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 30),

                // Input Fields
                _buildTextField("Email", false),
                const SizedBox(height: 20),
                _buildTextField("Password", true),
                const SizedBox(height: 20),
                _buildTextField("Confirm Password", true),

                const SizedBox(height: 30),

                // Sign in Button
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
                    "Sign in",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 15),

                // Create new account Button
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Create new account",
                    style: TextStyle(fontSize: 16, color: Color(0xff494949)),
                  ),
                ),

                const SizedBox(height: 30),

                // Social Media Sign-in
                const Text(
                  "Or continue with",
                  style: TextStyle(fontSize: 14, color: Color(0xff1f41bb)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom Text Field Widget
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
