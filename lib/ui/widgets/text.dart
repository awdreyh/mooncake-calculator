import 'package:flutter/material.dart';

class LabelWithSpacing extends StatelessWidget {
  final String label;

  const LabelWithSpacing({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
