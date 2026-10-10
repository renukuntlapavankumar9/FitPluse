// ============================================================================
// FitPulse Mobile App — Food Search Screen Widget Tests
// Week 4: API Integration and Asynchronous Data Handling
// Validates: UI rendering, asynchronous state transitions, loading, error, and list states
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitpulse_app/core/models/food_item_model.dart';
import 'package:fitpulse_app/core/services/api_exception.dart';
import 'package:fitpulse_app/core/services/food_api_service.dart';
import 'package:fitpulse_app/features/nutrition_api/food_search_screen.dart';

class FakeFoodApiService extends FoodApiService {
  final Future<List<FoodItem>> Function(String query) onSearch;

  FakeFoodApiService(this.onSearch);

  @override
  Future<List<FoodItem>> searchFood(
    String query, {
    int pageSize = 12,
    bool bypassCache = false,
  }) {
    return onSearch(query);
  }
}

void main() {
  group('FoodSearchScreen Widget Tests', () {
    testWidgets('TC-WGT-001: Renders search bar, header, and quick category chips', (tester) async {
      final fakeService = FakeFoodApiService((query) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: FoodSearchScreen(apiService: fakeService),
        ),
      );
      await tester.pump(); // Start search
      await tester.pump(const Duration(milliseconds: 100)); // Complete async search

      expect(find.text('Nutrition Database API'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Chicken'), findsOneWidget);
      expect(find.text('Greek Yogurt'), findsOneWidget);
    });

    testWidgets('TC-WGT-002: Displays food cards on successful asynchronous API response', (tester) async {
      final mockFoods = [
        const FoodItem(
          id: 'test-1',
          name: 'Organic Rolled Oats',
          brand: 'Quaker Fitness',
          caloriesPer100g: 375.0,
          proteinPer100g: 13.0,
          carbsPer100g: 65.0,
          fatPer100g: 7.0,
          nutriScore: 'a',
        ),
      ];

      final fakeService = FakeFoodApiService((query) async => mockFoods);

      await tester.pumpWidget(
        MaterialApp(
          home: FoodSearchScreen(apiService: fakeService),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Organic Rolled Oats'), findsOneWidget);
      expect(find.text('Quaker Fitness'), findsOneWidget);
      expect(find.text('375 kcal'), findsOneWidget);
      expect(find.text('13.0g'), findsOneWidget);
      expect(find.text('GRADE A'), findsOneWidget);
    });

    testWidgets('TC-WGT-003: Displays friendly error message and Retry button on network failure', (tester) async {
      final fakeService = FakeFoodApiService((query) async {
        throw const NetworkException('Connection to food database timed out.');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: FoodSearchScreen(apiService: fakeService),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Data Retrieval Issue Encountered'), findsOneWidget);
      expect(find.text('Connection to food database timed out.'), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);
      expect(find.text('Use Cached Data'), findsOneWidget);
    });
  });
}

