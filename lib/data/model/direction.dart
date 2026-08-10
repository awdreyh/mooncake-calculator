class Direction {
  final String stepIndex; // eg: '步骤1'
  final String stepTitle;
  final String stepDescription;
  final String? stepImage; // Optional image for this step

  Direction({
    required this.stepIndex,
    required this.stepTitle,
    required this.stepDescription,
    this.stepImage,
  });

  Map<String, dynamic> toMap() => {
        'stepIndex': stepIndex,
        'stepTitle': stepTitle,
        'stepDescription': stepDescription,
        'stepImage': stepImage,
      };

  factory Direction.fromMap(Map<String, dynamic> map) => Direction(
        stepIndex: map['step_index'] as String? ?? map['stepIndex'] as String,
        stepTitle: map['step_title'] as String? ?? map['stepTitle'] as String,
        stepDescription: map['step_description'] as String? ?? map['stepDescription'] as String,
        stepImage: map['step_image'] as String? ?? map['stepImage'] as String?,
      );
}