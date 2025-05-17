import 'package:flutter/material.dart';

class RegisterRadioButton extends StatelessWidget {
  const RegisterRadioButton({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  final String title;
  final String value;
  final String groupValue;
  final void Function(String? value) onChanged;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RadioListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey),
          ),
          contentPadding: EdgeInsets.all(0),
          visualDensity: VisualDensity.compact,
          title: Text(title),
          value: value,
          groupValue: groupValue,
          onChanged: onChanged),
    );
  }
}
