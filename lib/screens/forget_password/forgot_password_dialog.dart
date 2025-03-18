import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'services/password_reset_service.dart';
import 'widgets/success_dialog.dart';
import 'widgets/error_dialog.dart';
import 'widgets/email_not_found_dialog.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({Key? key}) : super(key: key);

  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PasswordResetService _resetService = PasswordResetService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        final email = _emailController.text.trim();
        print("Attempting to verify and reset password for: $email");

        final result = await _resetService.verifyEmailAndSendReset(email);

        setState(() {
          _isProcessing = false;
        });

        Navigator.of(context).pop(); // Close the dialog

        if (result.success) {
          print("Email verified successfully, reset email sent");
          _showSuccessDialog(result.message!);
        } else {
          if (result.emailExists == false) {
            print("Email not found in Firebase Auth");
            _showEmailNotFoundDialog();
          } else {
            print("Error during password reset: ${result.message}");
            _showErrorDialog(result.message!);
          }
        }
      } catch (e) {
        print("Exception during password reset: $e");
        setState(() {
          _isProcessing = false;
        });
        Navigator.of(context).pop(); // Close the dialog
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => SuccessDialog(message: message),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(errorMessage: errorMessage),
    );
  }

  void _showEmailNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => const EmailNotFoundDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.forgotPassword),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.enterEmailForReset),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.email,
                filled: true,
                fillColor: const Color(0xfff1f4ff),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xff1f41bb), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.emailRequired;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return AppLocalizations.of(context)!.invalidEmail;
                }
                return null;
              },
            ),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: _isProcessing ? null : _handleResetPassword,
          child: Text(AppLocalizations.of(context)!.reset),
        ),
      ],
    );
  }
}

