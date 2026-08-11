import 'ingredient.dart';
import 'direction.dart';

class Recipe {
  final String id;
  final String name; // eg: '祖母的广式月饼食谱'
  final String? typeId; 
  final int quantity;
  final int size;
  final double? ratio;  //ratio is the percentage of dough weight / total weight
  final String? description;
  final List<Ingredient> ingredients;
  final bool? isFavorite;
  final double? rating;
  final String? url;
  final String? comment;
  final List<Direction>? directions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.name, 
    required this.typeId,
    required this.quantity,
    required this.size,
    required this.ratio,     
    this.description,
    required this.ingredients,
    this.isFavorite = false,
    this.rating,
    this.url,
    this.comment,
    this.directions,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();



  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'typeId': typeId,
    'quantity': quantity,
    'size': size,
    'ratio': ratio,
    'description': description,
    'isFavorite': isFavorite,
    'rating': rating,
    'url': url,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Recipe.fromMap(Map<String, dynamic> map) {
    final isFavoriteValue = map['isFavorite'] ?? map['is_favorite'];
    final createdAtValue = map['createdAt'] ?? map['created_at'];
    final updatedAtValue = map['updatedAt'] ?? map['updated_at'];

    bool? parsedFavorite;
    if (isFavoriteValue != null) {
      if (isFavoriteValue is bool) {
        parsedFavorite = isFavoriteValue;
      } else if (isFavoriteValue is int) {
        parsedFavorite = isFavoriteValue == 1;
      } else {
        parsedFavorite = isFavoriteValue.toString().toLowerCase() == 'true';
      }
    }

    final ingredientsData = map['ingredients'] as List<dynamic>?;
    final directionsData = map['directions'] as List<dynamic>?;

    return Recipe(
      id: map['id'] == null ? '' : map['id'].toString(),
      name: map['name'] as String,
      typeId: map['typeId'] == null ? '' : map['typeId'].toString(),
      quantity: map['quantity'] as int,
      size: map['size'] as int,
      ratio: (map['ratio'] as num?)?.toDouble(),   
      description: map['description'] as String?,
      ingredients: ingredientsData == null
          ? <Ingredient>[]
          : ingredientsData
              .map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
              .toList(),
      isFavorite: parsedFavorite,
      rating: (map['rating'] as num?)?.toDouble(),
      url: map['url'] as String?,
      comment: map['comment'] as String?,
      directions: directionsData?.map((d) => Direction.fromMap(d as Map<String, dynamic>))
              .toList(),
      createdAt: createdAtValue == null
          ? DateTime.now()
          : DateTime.parse(createdAtValue as String),
      updatedAt: updatedAtValue == null
          ? DateTime.now()
          : DateTime.parse(updatedAtValue as String),
    );
  }


}

    

   