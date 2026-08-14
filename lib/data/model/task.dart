import 'ingredient.dart';
import 'dart:convert';

class Task {
  final String id;
  final String doughRecipeId;
  final String fillingRecipeId;
  final int size;
  final int quantity;
  final double ratio; //ratio is the percentage of dough weight / total weight
  final List<Ingredient> ingredients;
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? comment;
  final double? rating;
  final bool? isCompleted;

  Task({
    required this.id,
    required this.doughRecipeId,
    required this.fillingRecipeId,
    required this.size,
    required this.quantity,
    required this.ratio,
    required this.ingredients,
    this.imagePaths = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.comment,
    this.rating,
    bool? isCompleted,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       isCompleted = isCompleted ?? false;

  Map<String, dynamic> toMap() => {
    'id': id,
    'dough_recipe_id': doughRecipeId,
    'filling_recipe_id': fillingRecipeId,
    'size': size,
    'quantity': quantity,  
    'ratio': ratio,
    'image_paths': jsonEncode(imagePaths),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'comment': comment,
    'is_completed': isCompleted,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] == null ? '' : map['id'].toString(),
    doughRecipeId: map['dough_recipe_id'] == null
        ? ''
        : map['dough_recipe_id'].toString(),
    fillingRecipeId: map['filling_recipe_id'] == null
        ? ''
        : map['filling_recipe_id'].toString(),
    size: map['size'] as int,
    quantity: map['quantity'] as int,
    ratio: (map['ratio'] as num).toDouble(),
    ingredients: map['ingredients'] == null
        ? <Ingredient>[]
        : (map['ingredients'] as List<dynamic>)
              .map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
              .toList(),
    imagePaths: map['image_paths'] == null
        ? <String>[]
        : (map['image_paths'] is String
              ? (jsonDecode(map['image_paths'] as String) as List<dynamic>)
                    .map((item) => item.toString())
                    .toList()
              : (map['image_paths'] as List<dynamic>)
                    .map((item) => item.toString())
                    .toList()),
    createdAt: map['created_at'] == null
        ? DateTime.now()
        : DateTime.parse(map['created_at'] as String),
    updatedAt: map['updated_at'] == null
        ? DateTime.now()
        : DateTime.parse(map['updated_at'] as String),
    isCompleted: map['is_completed'] == null
        ? null
        : (map['is_completed'] is int
              ? (map['is_completed'] as int) == 1
              : map['is_completed'] as bool),
    rating: map['rating'] == null ? null : (map['rating'] as num).toDouble(),
    comment: map['comment'] as String?,
  );

  Task copyWith({
    String? id,
    String? doughRecipeId,
    String? fillingRecipeId,
    int? size,
    int? quantity,
    double? ratio,
    List<Ingredient>? ingredients,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? comment,
    double? rating,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      doughRecipeId: doughRecipeId ?? this.doughRecipeId,
      fillingRecipeId: fillingRecipeId ?? this.fillingRecipeId,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      ratio: ratio ?? this.ratio,
      ingredients: ingredients ?? this.ingredients,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
