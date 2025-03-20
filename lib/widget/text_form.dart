import 'package:flutter/material.dart';

class TextForm extends StatefulWidget {
  final ValueChanged<String> onChanged; // Callback function
  final String label;

  const TextForm({super.key, required this.onChanged, required this.label});

  @override
  TextFormState createState() => TextFormState();
}

class TextFormState extends State<TextForm> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      widget.onChanged(textController.text); // Call onChanged when text changes
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
