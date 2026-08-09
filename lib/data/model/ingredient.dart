enum UnitType {
  g,
  ml,
  cup,
  tsp,
  tbsp;

  // Convert enum → string
  String toMap() => name;

  // Convert string → enum
  static UnitType fromMap(String value) {
    return UnitType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => UnitType.g,
    );
  }
}



class Ingredient {
  final String id;
  final String name;
  final double amount;
  final UnitType unit;


  Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'amount': amount,
    'unit': unit.toMap(),

  };

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] == null ? '' : map['id'].toString(),
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      unit: UnitType.fromMap(map['unit'] as String),

    );
  } 


}