// ignore_for_file: file_names

import 'package:flutter/material.dart';

class RegisterPopup extends StatelessWidget {
  final VoidCallback onClose;

  const RegisterPopup({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Welcome!"),
      content: Text("Please register to continue using the app."),
      actions: [
        TextButton(
          onPressed: onClose,
          child: Text("OK"),
        ),
      ],
    );
  }
}
