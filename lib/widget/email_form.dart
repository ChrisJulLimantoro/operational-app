import 'package:flutter/material.dart';

class EmailForm extends StatefulWidget {
  final ValueChanged<String> onChanged; // Allow null if invalid

  const EmailForm({super.key, required this.onChanged});

  @override
  EmailFormState createState() => EmailFormState();
}

class EmailFormState extends State<EmailForm> {
  final TextEditingController emailController = TextEditingController();
  String? errorText;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      final email = emailController.text;
      if (_isValidEmail(email)) {
        setState(() => errorText = null); // Clear error
        widget.onChanged(email); // Send valid email
      } else if (email != '') {
        setState(() => errorText = "Invalid email format");
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Enter Email',
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
    );
  }
}
