import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/model/type.dart';
import '../../ui/core/app_theme.dart';
import '../utils/seeds_strings.dart';
import '../../ui/utils/language_provider.dart';
import 'package:provider/provider.dart';

class StyleImageButton extends StatelessWidget {
  final String title;
  final Type type;
  final bool selected;
  final VoidCallback onTap;

  const StyleImageButton({
    super.key,
    required this.title,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final lang = languageProvider.languageCode;
    final text = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    const placeholderImage = 'assets/images/types/placeholder.jpg';
    final imagePath = type.imagePath?.trim();
    final isLocalFile =
        imagePath != null &&
        imagePath.isNotEmpty &&
        !imagePath.startsWith('assets/');

    final image = isLocalFile
        ? Image.file(
            File(imagePath),
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(),
          )
        : Image.asset(
            imagePath?.isNotEmpty == true ? imagePath! : placeholderImage,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(),
          );

    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.borderLight : colorScheme.outline,
              width: 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(6),
                      blurRadius: 2,
                      spreadRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(7),
                ),
                child: image,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : AppColors.sectionBg,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(7),
                    ),
                  ),
                  child: Center(
                    child: Text(SeedsStrings.get(type.name, lang),
                      
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelLarge?.copyWith(
                        color: selected
                            ? AppColors.cream
                            : colorScheme.onSurface,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _placeholder() => Container(
  height: 100,
  color: AppColors.espresso,
  child: Icon(Icons.image_not_supported, color: AppColors.espressoLight),
);

class StyleTypeSelectionSection extends StatelessWidget {
  final String title;
  final List<Type> types;
  final Type? selectedType;
  final ValueChanged<Type> onTypeSelected;
  final bool showMatchedDoughTypes;
  final String matchedDoughLabel;
  final List<Type> doughTypes;
  final List<Type> selectedMatchedDoughTypes;
  final ValueChanged<Type> onMatchedDoughTypeToggled;

  const StyleTypeSelectionSection({
    super.key,
    required this.title,
    required this.types,
    required this.selectedType,
    required this.onTypeSelected,
    required this.showMatchedDoughTypes,
    required this.matchedDoughLabel,
    required this.doughTypes,
    required this.selectedMatchedDoughTypes,
    required this.onMatchedDoughTypeToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              final selected = selectedType?.id == type.id;
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == types.length - 1 ? 0 : 0,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 12,
                  child: StyleImageButton(
                    title: type.name,
                    type: type,
                    selected: selected,
                    onTap: () => onTypeSelected(type),
                  ),
                ),
              );
            },
          ),
        ),
        if (showMatchedDoughTypes) ...[
          const SizedBox(height: 16),
          Text(
            matchedDoughLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doughTypes.map((type) {
              final selected = selectedMatchedDoughTypes.any(
                (item) => item.id == type.id,
              );
              return FilterChip(
                label: Text(type.name),
                selected: selected,
                onSelected: (_) => onMatchedDoughTypeToggled(type),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
