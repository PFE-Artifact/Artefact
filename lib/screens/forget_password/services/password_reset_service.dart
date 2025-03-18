import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetResult {
  final bool success;
  final String? message;
  final bool? emailExists;

  PasswordResetResult({
    required this.success,
    this.message,
    this.emailExists,
  });
}

class PasswordResetService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Verifies if the email exists in Firebase Authentication and sends a password reset email if it does
  Future<PasswordResetResult> verifyEmailAndSendReset(String email) async {
    try {
      // First try to send the password reset email directly
      // Firebase will handle the verification internally
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      // If we reach here, the email exists and reset email was sent
      return PasswordResetResult(
        success: true,
        emailExists: true,
        message: 'Password reset instructions have been sent to your email',
      );
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Exception: ${e.code} - ${e.message}");

      // Check specific error codes
      if (e.code == 'user-not-found') {
        return PasswordResetResult(
          success: false,
          emailExists: false,
          message: 'Email not found in our records',
        );
      }

      // Handle other Firebase Auth errors
      return PasswordResetResult(
        success: false,
        message: e.message ?? 'An error occurred while verifying email',
      );
    } catch (e) {
      print("General Exception: $e");
      return PasswordResetResult(
        success: false,
        message: e.toString(),
      );
    }
  }
}

