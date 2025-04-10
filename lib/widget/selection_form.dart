import 'package:flutter/material.dart';

class SelectionForm extends StatefulWidget {
  final ValueChanged<String> onChanged; // Callback function
  final List<Map<String, dynamic>> options; // List of selectable options
  final String label; // Label for the dropdown

  const SelectionForm({
    super.key,
    required this.onChanged,
    required this.options,
    required this.label,
  });

  @override
  SelectionFormState createState() => SelectionFormState();
}

class SelectionFormState extends State<SelectionForm> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedOption,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(),
      ),
      items:
          widget.options.map((Map<String, dynamic> option) {
            return DropdownMenuItem<String>(
              value: option['id'],
              child: Text(option['value']),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          selectedOption = value;
        });
        if (value != null) {
          widget.onChanged(value);
        }
      },
    );
  }
}
