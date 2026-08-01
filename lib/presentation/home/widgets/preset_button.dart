import 'package:flutter/material.dart';

class PresetButton extends StatelessWidget {
  final int amount;
  final VoidCallback onPressed;
  final IconData icon;

  const PresetButton({
    super.key,
    required this.amount,
    required this.onPressed,
    this.icon = Icons.water_drop,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text('$amount ml'),
    );
  }
}
