import 'package:flutter/material.dart';

import '../../ui/core/app_theme.dart';

class InfoChips extends StatelessWidget {
  final int qty;
  final int size;
  final String ratio;
  final bool displayRatio;


  const InfoChips({
    super.key,
    required this.qty,
    required this.size,
    required this.ratio,
    this.displayRatio = true,

  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        Flexible(
          child: Chip(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            label: Text(' $qty pcs', overflow: TextOverflow.ellipsis),
            backgroundColor: AppColors.sectionBg,
          ),
        ),
        Flexible(
          child: Chip(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            label: Text(' $size g', overflow: TextOverflow.ellipsis),
            backgroundColor: AppColors.sectionBg,
          ),
        ),
        if (displayRatio)
          Flexible(
            child: Chip(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(' $ratio', overflow: TextOverflow.ellipsis),
              backgroundColor: AppColors.sectionBg,
            ),
          ),
      ],
    );
  }
}
