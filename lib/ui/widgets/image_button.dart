import 'package:flutter/material.dart';
import '../../db/model/type.dart';

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
    final imageAsset = (type.imagePath ?? 'placeholder').trim();


    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: selected ? 1 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(imageAsset, height: 100, fit: BoxFit.cover),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: types.map((type) {
            final selected = selectedType?.id == type.id;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: StyleImageButton(
                  title: type.name,
                  type: type,
                  selected: selected,
                  onTap: () => onTypeSelected(type),
                ),
              ),
            );
          }).toList(),
        ),
        if (showMatchedDoughTypes) ...[
          const SizedBox(height: 16),
          Text(
            matchedDoughLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
