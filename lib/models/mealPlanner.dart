class Meal {
  final DateTime date;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snacks'
  final String recipeId; // Now matches the String representation of ObjectId

  Meal({
    required this.date,
    required this.mealType,
    required this.recipeId,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    try {
      return Meal(
        date: DateTime.parse(json['date'] as String),
        mealType: json['mealType'] as String,
        recipeId: json['recipeId'] is Map
            ? json['recipeId']['\$oid']?.toString() ?? ''
            : json['recipeId']?.toString() ?? '',
      );
    } catch (e) {
      throw FormatException('Failed to parse Meal: $e');
    }
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'mealType': mealType,
        'recipeId': recipeId,
      };
}

class MealPlanner {
  final String id;
  final String userId;
  final List<Meal> meals;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealPlanner({
    required this.id,
    required this.userId,
    required this.meals,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealPlanner.fromJson(Map<String, dynamic> json) {
    try {
      return MealPlanner(
        id: json['_id'] is Map
            ? json['_id']['\$oid']?.toString() ?? ''
            : json['_id']?.toString() ?? '',
        userId: json['userId'] is Map
            ? json['userId']['\$oid']?.toString() ?? ''
            : json['userId']?.toString() ?? '',
        meals: (json['meals'] as List)
            .map((e) => Meal.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      throw FormatException('Failed to parse MealPlanner: $e');
    }
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'meals': meals.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
