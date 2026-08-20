import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/language_provider.dart';
import 'package:provider/provider.dart';

import 'selection_buttons.dart';

/// The quantity, size, and dough-to-filling ratio inputs used when configuring
/// a task. The owning page supplies the controllers and selection state so it
/// can use the values when creating a task.
class TaskConfigurationFields extends StatelessWidget {
  const TaskConfigurationFields({
    super.key,

    required this.quantityController,
    required this.sizeController,
    required this.ratioController,
    required this.selectedQuantity,
    required this.selectedSize,
    required this.selectedRatio,
    required this.onQuantitySelected,
    required this.onSizeSelected,
    required this.onRatioSelected,
    this.quantityError,
    this.sizeError,
    this.ratioError,
  });

  final TextEditingController quantityController;
  final TextEditingController sizeController;
  final TextEditingController ratioController;
  final int? selectedQuantity;
  final int? selectedSize;
  final String? selectedRatio;
  final ValueChanged<int> onQuantitySelected;
  final ValueChanged<int> onSizeSelected;
  final ValueChanged<String> onRatioSelected;
  final String? quantityError;
  final String? sizeError;
  final String? ratioError;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
  final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: true,
    );
  final lang = languageProvider.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputRow(
          label: AppStrings.get('quantity', lang),
          controller: quantityController,
          keyboardType: TextInputType.number,
          labelStyle: text.titleSmall,
          inputStyle: text.titleSmall,
          errorText: quantityError,
        ),
        const SizedBox(height: 8),
        OptionButtons(
          values: const [4, 8, 10, 16],
          onSelected: onQuantitySelected,
          selectedValue: selectedQuantity,
        ),
        const SizedBox(height: 20),
        _buildInputRow(
          label: AppStrings.get('size', lang),
          controller: sizeController,
          keyboardType: TextInputType.number,
          labelStyle: text.titleSmall,
          inputStyle: text.titleSmall,
          errorText: sizeError,
        ),
        const SizedBox(height: 8),
        OptionButtons(
          values: const [35, 50, 75, 100],
          onSelected: onSizeSelected,
          selectedValue: selectedSize,
        ),
        const SizedBox(height: 20),
        _buildInputRow(
          label: AppStrings.get('ratio', lang),
          controller: ratioController,
          keyboardType: TextInputType.text,
          labelStyle: text.titleSmall,
          inputStyle: text.titleSmall,
          errorText: ratioError,
        ),
        const SizedBox(height: 8),
        RatioButtons(
          onSelected: onRatioSelected,
          selectedValue: selectedRatio,
        ),
      ],
    );
  }

  Widget _buildInputRow({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required TextStyle? labelStyle,
    TextStyle? inputStyle,
    String? errorText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              errorText: errorText != null && errorText.isNotEmpty
                  ? errorText
                  : null,
            ),
            style: inputStyle,
          ),
        ),
      ],
    );
  }
}
