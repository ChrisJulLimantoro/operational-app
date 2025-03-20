import 'package:flutter/material.dart';

class OperationSelectionForm extends StatefulWidget {
  final ValueChanged<String> onChanged; // Callback function
  final List<Map<String, dynamic>> options; // List of selectable options

  const OperationSelectionForm({
    super.key,
    required this.onChanged,
    required this.options,
  });

  @override
  OperationSelectionFormState createState() => OperationSelectionFormState();
}

class OperationSelectionFormState extends State<OperationSelectionForm> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedOption,
      decoration: const InputDecoration(
        labelText: 'Select Operation',
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
