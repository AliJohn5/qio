import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      onChanged: (bool newValue) => onChanged(newValue),
      value: value,
      thumbColor: WidgetStateProperty.all<Color>(Colors.black),
      thumbIcon: WidgetStateProperty.all<Icon>(Icon(
        value ? Icons.check : Icons.clear_outlined,
        color: Theme.of(context).colorScheme.outline,
      )),
      inactiveTrackColor: Theme.of(context).colorScheme.outline,
    );
  }
}
