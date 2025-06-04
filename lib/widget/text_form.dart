import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TextForm extends StatefulWidget {
  final ValueChanged<String> onChanged; // Returns raw like "-100000.75"
  final String label;
  final String? initialValue;
  final bool isNumber;

  const TextForm({
    super.key,
    required this.onChanged,
    required this.label,
    this.initialValue,
    this.isNumber = false,
  });

  @override
  State<TextForm> createState() => TextFormState();
}

class TextFormState extends State<TextForm> {
  final TextEditingController textController = TextEditingController();
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 2,
  );

  String rawValue = '';
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();

    rawValue = widget.initialValue ?? '';
    if (widget.isNumber && rawValue.isNotEmpty) {
      final parsed = double.tryParse(rawValue.replaceAll(',', '.'));
      if (parsed != null) {
        textController.text = _formatNumber(parsed);
      } else {
        textController.text = rawValue;
      }
    } else {
      textController.text = rawValue;
    }

    textController.addListener(_handleChange);
  }

  void _handleChange() {
    if (_isFormatting) return;

    final input = textController.text;

    if (!widget.isNumber) {
      rawValue = input;
      widget.onChanged(rawValue);
      return;
    }

    // Replace thousand separator, use . as decimal point
    final normalized = input
        .replaceAll('.', '') // remove thousands
        .replaceAll(',', '.'); // replace decimal comma with dot

    // Allow negative sign and decimal only once
    final validInput = RegExp(r'^-?\d*\.?\d*$');

    if (validInput.hasMatch(normalized)) {
      rawValue = normalized;
      widget.onChanged(rawValue);
    }
  }

  String _formatNumber(double number) {
    return number < 0
        ? '-${formatter.format(number.abs())}'
        : formatter.format(number);
  }

  void _formatTextIfValid() {
    if (!widget.isNumber) return;

    final cleaned = rawValue.replaceAll(',', '.');
    final number = double.tryParse(cleaned);
    if (number == null) return;

    final formatted = _formatNumber(number);

    _isFormatting = true;
    textController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isFormatting = false;
  }

  @override
  void dispose() {
    textController.removeListener(_handleChange);
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      onEditingComplete: _formatTextIfValid, // Format only when editing is done
    );
  }
}
