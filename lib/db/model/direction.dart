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
        stepIndex: map['stepIndex'] as String,
        stepTitle: map['stepTitle'] as String,
        stepDescription: map['stepDescription'] as String,
        stepImage: map['stepImage'] as String?,
      );
}