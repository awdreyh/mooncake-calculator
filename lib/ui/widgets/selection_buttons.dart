import 'package:flutter/material.dart';
import '../../ui/core/app_theme.dart';

class OptionButtons extends StatelessWidget {
  final List<int> values;
  final ValueChanged<int> onSelected;
  final int? selectedValue;

  const OptionButtons({
    super.key,
    required this.values,
    required this.onSelected,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(  
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: values.map((value) {
        final isSelected = selectedValue == value;
        return Expanded(
          child: OutlinedButton(
          onPressed: () => onSelected(value),
            style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected
                      ?  AppColors.sectionBg
                      : AppColors.cream,  
                  foregroundColor: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(                  
                    vertical: 4,
                  ),
                ),
          child: Text(value.toString()),
        ));
      }).toList(),
    );
  }
}

class RatioButtons extends StatelessWidget {
  final ValueChanged<String> onSelected;
  final String? selectedValue;  

  const RatioButtons({
    super.key,
    required this.onSelected,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    final ratios = ['2:8', '3:7', '4:6', '5:5'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      children: ratios.map((value) {
        final isSelected = selectedValue == value;
        return Expanded(
          child:OutlinedButton(
          onPressed: () => onSelected(value),
            style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.sectionBg
                      : null,   
                  foregroundColor: isSelected
                      ? AppColors.textSecondary
                      : AppColors.textSecondary,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
          child: Text(value),
        ));
      }).toList(),
    );
  }
}
