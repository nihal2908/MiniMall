import 'package:flutter/material.dart';

class CustomDropdownFormField extends StatefulWidget {
  final String selectedValue;
  final List<String> items;
  final String? labelText;
  final String? Function(String?) validator;
  final ValueChanged<String?>? onChanged;

  const CustomDropdownFormField({
    required this.selectedValue,
    required this.items,
    this.labelText,
    required this.validator,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _CustomDropdownFormFieldState createState() => _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return DropdownButtonFormField<String>(
          value: selectedValue,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: widget.labelText,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderSide: const BorderSide(),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          items: widget.items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedValue = value!;
              widget.onChanged;
            });

          },
          validator: widget.validator,
        );
      },
    );
  }
}
