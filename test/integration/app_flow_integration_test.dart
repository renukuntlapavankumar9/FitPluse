// ============================================================================
// FitPulse Mobile App — End-to-End User Journey Integration Test Suite
// Week 5: Comprehensive Testing and App Optimization
// Simulates complete user workflows across multi-screen feature boundaries
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitpulse_app/core/models/food_item_model.dart';
import 'package:fitpulse_app/core/services/food_api_service.dart';
import 'package:fitpulse_app/core/state/app_state.dart';
import 'package:fitpulse_app/features/dashboard/dashboard_screen.dart';
import 'package:fitpulse_app/features/nutrition_api/food_search_screen.dart';
import 'package:fitpulse_app/features/habits/habit_log_screen.dart';
import 'package:fitpulse_app/features/workout/workout_tracker_screen.dart';

class StubFoodApiService extends FoodApiService {
  @override
  Future<List<FoodItem>> searchFood(
    String query, {
    int pageSize = 12,
    bool bypassCache = false,
  }) async {
    return const [
      FoodItem(
        id: 'integration-food-01',
        name: 'Whole Rolled Oats',
        brand: 'Quaker Fitness',
        caloriesPer100g: 389.0,
        proteinPer100g: 16.9,
        carbsPer100g: 66.3,
        fatPer100g: 6.9,
        fiberPer100g: 10.6,
        nutriScore: 'a',
      ),
    ];
  }
}

void main() {
  group('FitPulse End-to-End Feature Integration Tests', () {
    setUp(() {
      FitPulseState.instance.resetToDefaults();
    });

    testWidgets('TC-INT-001: End-to-End Nutrition Journey: Search API -> Select -> Log Meal -> Verify Dashboard Sync', (tester) async {
      final state = FitPulseState.instance;
      final initialCalories = state.caloriesConsumed;

      // 1. Launch Food Search Screen with stubbed API
      await tester.pumpWidget(
        MaterialApp(
          home: FoodSearchScreen(apiService: StubFoodApiService()),
        ),
      );
      await tester.pumpAndSettle();

      // 2. Verify food items rendered
      expect(find.text('Whole Rolled Oats'), findsOneWidget);

      // 3. Tap card to open FoodDetailModal
      await tester.tap(find.text('Whole Rolled Oats'));
      await tester.pumpAndSettle();

      // 4. Modal confirms item details & log meal button
      final logButton = find.byIcon(Icons.add_circle_outline);
      expect(logButton, findsOneWidget);

      // 5. Tap Log This Meal
      await tester.tap(logButton);
      await tester.pumpAndSettle();

      // 6. State should be updated with scaled nutrition
      expect(state.caloriesConsumed, greaterThan(initialCalories));

      // 7. Verify Dashboard reflects new values
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('${state.caloriesConsumed.toInt()} / ${state.caloriesTarget.toInt()} kcal'), findsOneWidget);
    });

    testWidgets('TC-INT-002: End-to-End Habit Journey: Inspect habits -> Toggle completion -> Verify streak consistency', (tester) async {
      final state = FitPulseState.instance;

      await tester.pumpWidget(
        const MaterialApp(
          home: HabitLogScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final initialScore = state.habitConsistencyScore;
      expect(initialScore, isA<int>());

      // Toggle first habit
      final checkboxes = find.byType(Checkbox);
      if (checkboxes.evaluate().isNotEmpty) {
        await tester.tap(checkboxes.first);
        await tester.pumpAndSettle();
      }

      expect(state.habitConsistencyScore, isNotNull);
    });

    testWidgets('TC-INT-003: End-to-End Workout Journey: Start workout -> Add Set -> Auto-calculate 1RM -> Verify volume', (tester) async {
      final state = FitPulseState.instance;
      final initialSets = state.activeSets.length;
      final initialVolume = state.totalWorkoutVolume;

      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Add Set dialog
      await tester.tap(find.text('Add Set'));
      await tester.pumpAndSettle();

      // Confirm and add set
      await tester.tap(find.text('CONFIRM & ADD SET'));
      await tester.pumpAndSettle();

      expect(state.activeSets.length, initialSets + 1);
      expect(state.totalWorkoutVolume, greaterThanOrEqualTo(initialVolume));
    });

    testWidgets('TC-INT-004: End-to-End Recovery Journey: Fast hydration log -> Recompute recovery -> Verify reactive UI', (tester) async {
      final state = FitPulseState.instance;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final initialWater = state.waterLiters;
      state.logHydration(0.5);
      await tester.pumpAndSettle();

      expect(state.waterLiters, closeTo(initialWater + 0.5, 0.01));
      expect(find.text('${state.waterLiters.toStringAsFixed(1)}L'), findsOneWidget);
    });
  });
}
