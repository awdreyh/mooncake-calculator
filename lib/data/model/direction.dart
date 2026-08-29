class Direction {
    final String id;
  final int stepIndex; // eg: 1
  final String stepTitle;
  final String stepDescription;
  final String? stepImagePath; // Optional image for this step
  final String recipeId;

  Direction({
    required this.id,
    required this.stepIndex,
    required this.stepTitle,
    required this.stepDescription,
    this.stepImagePath,
    required this.recipeId,    
  });

  Map<String, dynamic> toMap() => {
        'recipe_id': recipeId,
        'step_index': stepIndex,
        'step_title': stepTitle,
        'step_description': stepDescription,
        'step_image_path': stepImagePath,
      };

  factory Direction.fromMap(Map<String, dynamic> map) => Direction(
        id: map['id']?.toString() ?? '',
        stepIndex: map['step_index'] as int? ?? map['stepIndex'] as int,
        stepTitle: map['step_title'] as String? ?? map['stepTitle'] as String,
        stepDescription: map['step_description'] as String? ?? map['stepDescription'] as String,
        stepImagePath: map['step_image_path'] as String? ?? map['stepImagePath'] as String?,
        recipeId: map['recipe_id'] as String? ?? map['recipeId'] as String,
      );
}