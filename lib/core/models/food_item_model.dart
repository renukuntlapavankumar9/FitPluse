// ============================================================================
// FitPulse Mobile App — Food & Nutrition Domain Model
// Week 4: API Integration and Asynchronous Data Handling
// Maps Open Food Facts REST API response payloads into strongly-typed objects
// ============================================================================

class FoodItem {
  final String id;
  final String name;
  final String brand;
  final String? imageUrl;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final String nutriScore;
  final double defaultServingGrams;

  const FoodItem({
    required this.id,
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0.0,
    this.nutriScore = 'unknown',
    this.defaultServingGrams = 100.0,
  });

  /// Factory constructor to safely parse JSON from Open Food Facts API
  /// Handles numeric and string representations with defensive fallbacks.
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};

    // Helper to safely extract double from either num or string
    double parseNutriment(List<String> keys) {
      for (final key in keys) {
        final val = nutriments[key];
        if (val != null) {
          if (val is num) return val.toDouble();
          if (val is String) {
            final parsed = double.tryParse(val);
            if (parsed != null) return parsed;
          }
        }
      }
      return 0.0;
    }

    final id = json['code']?.toString() ?? 
               json['id']?.toString() ?? 
               DateTime.now().millisecondsSinceEpoch.toString();

    final name = (json['product_name'] ?? 
                  json['product_name_en'] ?? 
                  json['generic_name'] ?? 
                  'Unnamed Fitness Food').toString().trim();

    final brand = (json['brands'] ?? 
                   json['brand_owner'] ?? 
                   'Generic / Verified').toString().trim();

    final imageUrl = json['image_front_small_url'] ?? 
                     json['image_thumb_url'] ?? 
                     json['image_url'];

    final kcal = parseNutriment(['energy-kcal_100g', 'energy-kcal', 'energy_100g']);
    final protein = parseNutriment(['proteins_100g', 'proteins']);
    final carbs = parseNutriment(['carbohydrates_100g', 'carbohydrates']);
    final fat = parseNutriment(['fat_100g', 'fat']);
    final fiber = parseNutriment(['fiber_100g', 'fiber']);

    final rawScore = (json['nutriscore_grade'] ?? json['nutrition_grades'] ?? 'unknown')
        .toString()
        .toLowerCase();
    final nutriScore = ['a', 'b', 'c', 'd', 'e'].contains(rawScore) ? rawScore : 'unknown';

    return FoodItem(
      id: id,
      name: name.isEmpty ? 'Unnamed Fitness Food' : name,
      brand: brand.isEmpty ? 'Fitness Standard' : brand,
      imageUrl: imageUrl is String && imageUrl.isNotEmpty ? imageUrl : null,
      caloriesPer100g: kcal.clamp(0.0, 900.0),
      proteinPer100g: protein.clamp(0.0, 100.0),
      carbsPer100g: carbs.clamp(0.0, 100.0),
      fatPer100g: fat.clamp(0.0, 100.0),
      fiberPer100g: fiber.clamp(0.0, 100.0),
      nutriScore: nutriScore,
      defaultServingGrams: 100.0,
    );
  }

  /// Calculates scaled calories for a customized serving size (in grams)
  double scaledCalories(double servingGrams) =>
      double.parse(((caloriesPer100g * servingGrams) / 100.0).toStringAsFixed(1));

  /// Calculates scaled protein for a customized serving size (in grams)
  double scaledProtein(double servingGrams) =>
      double.parse(((proteinPer100g * servingGrams) / 100.0).toStringAsFixed(1));

  /// Calculates scaled carbohydrates for a customized serving size (in grams)
  double scaledCarbs(double servingGrams) =>
      double.parse(((carbsPer100g * servingGrams) / 100.0).toStringAsFixed(1));

  /// Calculates scaled dietary fats for a customized serving size (in grams)
  double scaledFat(double servingGrams) =>
      double.parse(((fatPer100g * servingGrams) / 100.0).toStringAsFixed(1));

  /// Calculates scaled fiber for a customized serving size (in grams)
  double scaledFiber(double servingGrams) =>
      double.parse(((fiberPer100g * servingGrams) / 100.0).toStringAsFixed(1));

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'imageUrl': imageUrl,
    'caloriesPer100g': caloriesPer100g,
    'proteinPer100g': proteinPer100g,
    'carbsPer100g': carbsPer100g,
    'fatPer100g': fatPer100g,
    'fiberPer100g': fiberPer100g,
    'nutriScore': nutriScore,
  };
}

