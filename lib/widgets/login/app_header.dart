import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.star_border_purple500_outlined,
          size: 150,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 10, width: double.infinity),
        Text(
          'Qio',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
