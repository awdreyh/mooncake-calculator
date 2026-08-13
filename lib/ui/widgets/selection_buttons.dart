import 'package:flutter/material.dart';

class OptionButtons extends StatelessWidget {
  final List<int> values;
  final ValueChanged<int> onSelected;

  const OptionButtons({
    super.key,
    required this.values,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: values.map((value) {
        return ElevatedButton(
          onPressed: () => onSelected(value),
          child: Text(value.toString()),
        );

        
        // return OutlinedButton(
        //   onPressed: () => onSelected(value),
        //   child: Text(value.toString()),
        // );
      }).toList(),
    );
  }
} 

class RatioButtons extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const RatioButtons({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ratios = ['2:8', '3:7', '4:6', '5:5'];
    return Wrap(
      spacing: 8,
      children: ratios.map((value) {
        return OutlinedButton(
          onPressed: () => onSelected(value),
          child: Text(value),
        );
      }).toList(),
    );
  }
}
