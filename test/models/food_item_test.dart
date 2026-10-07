// ============================================================================
// FitPulse Mobile App — Food Item Model Unit Tests
// Week 4: API Integration and Asynchronous Data Handling
// Verifies deserialization, null-safety fallbacks, NutriScore parsing, and scaling
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:fitpulse_app/core/models/food_item_model.dart';

void main() {
  group('FoodItem Model Tests', () {
    test('TC-MOD-001: Correctly deserializes complete Open Food Facts JSON payload', () {
      final sampleJson = {
        'code': '737628064502',
        'product_name': 'Organic Rolled Oats',
        'brands': "Bob's Red Mill",
        'image_front_small_url': 'https://images.openfoodfacts.org/oats.jpg',
        'nutriments': {
          'energy-kcal_100g': 380.0,
          'proteins_100g': 13.5,
          'carbohydrates_100g': 68.0,
          'fat_100g': 6.5,
          'fiber_100g': 10.0,
        },
        'nutriscore_grade': 'a',
      };

      final item = FoodItem.fromJson(sampleJson);

      expect(item.id, equals('737628064502'));
      expect(item.name, equals('Organic Rolled Oats'));
      expect(item.brand, equals("Bob's Red Mill"));
      expect(item.imageUrl, equals('https://images.openfoodfacts.org/oats.jpg'));
      expect(item.caloriesPer100g, equals(380.0));
      expect(item.proteinPer100g, equals(13.5));
      expect(item.carbsPer100g, equals(68.0));
      expect(item.fatPer100g, equals(6.5));
      expect(item.fiberPer100g, equals(10.0));
      expect(item.nutriScore, equals('a'));
    });

    test('TC-MOD-002: Handles string representations of numeric nutriments', () {
      final sampleJson = {
        'code': '123456',
        'product_name': 'Whey Protein Powder',
        'brands': 'Optimum Nutrition',
        'nutriments': {
          'energy-kcal_100g': '400.5',
          'proteins_100g': '80.0',
          'carbohydrates_100g': '5.2',
          'fat_100g': '2.1',
          'fiber_100g': '1.0',
        },
        'nutriscore_grade': 'b',
      };

      final item = FoodItem.fromJson(sampleJson);

      expect(item.caloriesPer100g, equals(400.5));
      expect(item.proteinPer100g, equals(80.0));
      expect(item.carbsPer100g, equals(5.2));
      expect(item.fatPer100g, equals(2.1));
      expect(item.fiberPer100g, equals(1.0));
      expect(item.nutriScore, equals('b'));
    });

    test('TC-MOD-003: Defensive fallbacks for missing, null, or empty fields', () {
      final sampleJson = <String, dynamic>{};

      final item = FoodItem.fromJson(sampleJson);

      expect(item.name, equals('Unnamed Fitness Food'));
      expect(item.brand, equals('Generic / Verified'));
      expect(item.imageUrl, isNull);
      expect(item.caloriesPer100g, equals(0.0));
      expect(item.proteinPer100g, equals(0.0));
      expect(item.carbsPer100g, equals(0.0));
      expect(item.fatPer100g, equals(0.0));
      expect(item.nutriScore, equals('unknown'));
    });

    test('TC-MOD-004: Normalizes invalid NutriScore grades to unknown', () {
      final sampleJson = {
        'product_name': 'Energy Bar',
        'nutriscore_grade': 'z',
      };

      final item = FoodItem.fromJson(sampleJson);
      expect(item.nutriScore, equals('unknown'));
    });

    test('TC-MOD-005: Custom serving scaler calculates exact proportional macros', () {
      const item = FoodItem(
        id: '1',
        name: 'Chicken Breast',
        brand: 'Fresh Farm',
        caloriesPer100g: 165.0,
        proteinPer100g: 31.0,
        carbsPer100g: 0.0,
        fatPer100g: 3.6,
      );

      // Test 150g serving
      expect(item.scaledCalories(150.0), equals(247.5));
      expect(item.scaledProtein(150.0), equals(46.5));
      expect(item.scaledCarbs(150.0), equals(0.0));
      expect(item.scaledFat(150.0), equals(5.4));

      // Test 200g serving
      expect(item.scaledCalories(200.0), equals(330.0));
      expect(item.scaledProtein(200.0), equals(62.0));
    });
  });
}

