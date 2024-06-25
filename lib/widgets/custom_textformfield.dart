import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
final String labelText;
final TextEditingController controller;
final String? Function(String?) validator;
final bool? obscured;
final TextInputType? keyboard;

CustomTextFormField({
  required this.labelText,
  required this.controller,
  required this.validator,
  this.obscured,
  this.keyboard
});

@override
Widget build(BuildContext context) {
  return TextFormField(
    obscureText: obscured ?? false,
    decoration: InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderSide: const BorderSide(),
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    controller: controller,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: validator,
    keyboardType: keyboard ?? TextInputType.text,
  );
}
}