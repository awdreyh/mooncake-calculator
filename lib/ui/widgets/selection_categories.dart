import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/core/app_theme.dart';
import '../../ui/utils/app_strings.dart';
import '../../ui/utils/language_provider.dart';
import '../../../data/model/type.dart';

class OptionCategory extends StatelessWidget {
  final List<Category> values;
  final ValueChanged<Category> onSelected;
  final Category? selectedValue;

  const OptionCategory({
    super.key,
    required this.values,
    required this.onSelected,
    this.selectedValue,
  });
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: values.map((category) {
        final isSelected = selectedValue == category;
        final color = isSelected ? AppColors.accent : AppColors.accent;
        return Expanded(
          child: Card(
            color: isSelected ? color.withOpacity(0.12) : AppColors.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(
                color: isSelected ? color : AppColors.divider,
                width: isSelected ? 1 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => onSelected(category),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Icon(
                      category == Category.filling ? Icons.egg_alt : Icons.cookie,
                      color: category == Category.filling ? AppColors.accentRed : AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppStrings.get(category.toMap(), lang),
                        style: TextStyle(
                          color: category == Category.filling ? AppColors.accentRed : AppColors.accent,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
