/// A recipe category, e.g. "Seafood".
class MealCategory {
  final String name;
  final String thumbnail;

  const MealCategory({required this.name, required this.thumbnail});

  factory MealCategory.fromJson(Map<String, dynamic> json) => MealCategory(
        name: json['strCategory'] as String? ?? '',
        thumbnail: json['strCategoryThumb'] as String? ?? '',
      );
}

/// What a list of recipes shows: enough for a card.
class MealSummary {
  final String id;
  final String name;
  final String thumbnail;

  const MealSummary({required this.id, required this.name, required this.thumbnail});

  factory MealSummary.fromJson(Map<String, dynamic> json) => MealSummary(
        id: json['idMeal'] as String? ?? '',
        name: (json['strMeal'] as String? ?? '').trim(),
        thumbnail: json['strMealThumb'] as String? ?? '',
      );
}

class Ingredient {
  final String name;
  final String measure;

  const Ingredient({required this.name, required this.measure});
}

/// A full recipe with ingredients and steps.
class Meal extends MealSummary {
  final String category;
  final String area;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final String? videoUrl;

  const Meal({
    required super.id,
    required super.name,
    required super.thumbnail,
    required this.category,
    required this.area,
    required this.ingredients,
    required this.steps,
    this.videoUrl,
  });

  /// TheMealDB lists ingredients as strIngredient1..20 with matching
  /// strMeasure fields, many of them empty.
  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = (json['strIngredient$i'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;
      final measure = (json['strMeasure$i'] as String?)?.trim() ?? '';
      ingredients.add(Ingredient(name: name, measure: measure));
    }
    final video = (json['strYoutube'] as String?)?.trim();
    return Meal(
      id: json['idMeal'] as String? ?? '',
      name: (json['strMeal'] as String? ?? '').trim(),
      thumbnail: json['strMealThumb'] as String? ?? '',
      category: json['strCategory'] as String? ?? '',
      area: json['strArea'] as String? ?? json['strCountry'] as String? ?? '',
      ingredients: ingredients,
      steps: splitSteps(json['strInstructions'] as String? ?? ''),
      videoUrl: video == null || video.isEmpty ? null : video,
    );
  }

  /// Turns a block of instructions into steps: one per non-empty line,
  /// without "STEP 1" headings or leading numbers.
  static List<String> splitSteps(String instructions) {
    final heading = RegExp(r'^(step\s*\d+[:.)]?|\d+[.)])\s*', caseSensitive: false);
    return instructions
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim().replaceFirst(heading, '').trim())
        .where((line) => line.length > 1)
        .toList();
  }
}
