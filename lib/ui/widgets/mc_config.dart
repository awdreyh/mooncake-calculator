import 'package:flutter/material.dart';
import '../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../utils/app_strings.dart';
import '../utils/helper.dart';

import 'selectable_input.dart';

/// The quantity, size, and dough-to-filling ratio inputs used when configuring
/// a task. The owning page supplies the controllers and selection state so it
/// can use the values when creating a task.
class McConfig extends StatelessWidget {
  const McConfig({
    super.key,
    required this.onQuantitySelected,
    required this.onSizeSelected,
    required this.onRatioSelected,
  });

  final ValueChanged<int> onQuantitySelected;
  final ValueChanged<int> onSizeSelected;
  final ValueChanged<double> onRatioSelected;

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
        const SizedBox(height: 20),
        SelectableInput(
          keyboardType: TextInputType.number,
          options: [4, 8, 12, 16],
          defaultValue: 8,
          onChanged: (value) {
            if (value == null) return;
            onQuantitySelected(value);
          },
          labelText: AppStrings.get('quantity', lang),
        ),

        const SizedBox(height: 16),
        SelectableInput(
          keyboardType: TextInputType.number,
          options: [35, 50, 75, 100],
          defaultValue: 100,
          onChanged: (value) {
            if (value == null) return;
            onSizeSelected(value);
          },
          labelText: AppStrings.get('size', lang),
        ),

        const SizedBox(height: 16),

        SelectableRatioInput(
          keyboardType: TextInputType.text,
          options: ["2:8", "3:7", "4:6", "5:5"],
          defaultValue: "4:6",
          onChanged: (value) {
            onRatioSelected(Helper.stringToRatio(value));
          },
          labelText: AppStrings.get('ratio', lang),
        ),
      ],
    );
  }
}
