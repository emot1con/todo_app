import 'package:flutter/material.dart';

class TextForm extends StatefulWidget {
  const TextForm({
    super.key,
    required this.label,
    required this.icon,
    required this.validator,
    required this.onSaved,
    this.keyboardType,
  });

  final String label;
  final IconData icon;
  final FormFieldValidator validator;
  final TextInputType? keyboardType;
  final FormFieldSetter onSaved;

  @override
  State<TextForm> createState() => _TextFormState();
}

class _TextFormState extends State<TextForm> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(widget.icon),
      ),
      keyboardType: widget.keyboardType ?? TextInputType.text,
      validator: widget.validator,
      onSaved: widget.onSaved
    );
  }
}
