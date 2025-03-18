import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailNotFoundDialog extends StatelessWidget {
  const EmailNotFoundDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.info, color: Colors.orange, size: 28),
          const SizedBox(width: 10),
          Text(AppLocalizations.of(context)!.emailNotFound),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.emailNotRegistered),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.createAccountPrompt,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff1f41bb),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, "/register");
          },
          child: Text(AppLocalizations.of(context)!.register),
        ),
      ],
    );
  }
}

