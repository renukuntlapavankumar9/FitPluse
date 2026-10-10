// ============================================================================
// FitPulse Mobile App — Central Reactive State Provider Unit Test Suite
// Week 5: Comprehensive Testing and App Optimization
// Tests state updates, listener notifications, recovery formulas, and calculations
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:fitpulse_app/core/state/app_state.dart';

void main() {
  group('FitPulseState Comprehensive Unit Tests', () {
    late FitPulseState state;

    setUp(() {
      state = FitPulseState.instance;
      state.resetToDefaults();
    });

    test('TC-STA-001: Hydration logging updates volume and notifies listeners', () {
      int notifications = 0;
      state.addListener(() => notifications++);

      final initialWater = state.waterLiters;
      state.logHydration(0.5);

      expect(state.waterLiters, closeTo(initialWater + 0.5, 0.001));
      expect(notifications, 1);
    });

    test('TC-STA-002: Meal logging increments calories and macronutrients proportionally', () {
      int notifications = 0;
      state.addListener(() => notifications++);

      final initialCals = state.caloriesConsumed;
      final initialProtein = state.proteinGrams;
      final initialCarbs = state.carbsGrams;
      final initialFats = state.fatsGrams;

      state.logMeal(calories: 550, protein: 42, carbs: 60, fats: 15);

      expect(state.caloriesConsumed, initialCals + 550);
      expect(state.proteinGrams, initialProtein + 42);
      expect(state.carbsGrams, initialCarbs + 60);
      expect(state.fatsGrams, initialFats + 15);
      expect(notifications, 1);
    });

    test('TC-STA-003: Habit toggle flips isCompleted and updates consistency score', () {
      expect(state.habits.isNotEmpty, true);
      final habitId = state.habits.first.id;
      final initialStatus = state.habits.first.isCompleted;

      state.toggleHabit(habitId);
      expect(state.habits.first.isCompleted, !initialStatus);

      final score = state.habitConsistencyScore;
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });

    test('TC-STA-004: Adding custom workout set calculates Epley 1RM accurately', () {
      final set1 = WorkoutSet(setNum: 1, weight: 100.0, reps: 10);
      // Epley: 100 * (1 + 10 / 30) = 100 * 1.3333 = 133.33 kg
      expect(set1.estimatedOneRepMax, closeTo(133.33, 0.1));
      expect(set1.volume, 1000.0);

      final singleRepSet = WorkoutSet(setNum: 2, weight: 120.0, reps: 1);
      expect(singleRepSet.estimatedOneRepMax, 120.0);
    });

    test('TC-STA-005: Algorithmic Readiness Score clamps to valid bounds (15-99)', () {
      final metrics = ReadinessMetrics(
        sleepHours: 8.0,
        energyLevel: 9,
        sorenessLevel: 2,
        restingHeartRate: 55,
      );
      final score = metrics.readinessScore;
      expect(score, greaterThanOrEqualTo(15));
      expect(score, lessThanOrEqualTo(99));
      expect(metrics.recommendation.isNotEmpty, true);

      // Extreme exhaustion test
      final exhausted = ReadinessMetrics(
        sleepHours: 2.0,
        energyLevel: 1,
        sorenessLevel: 10,
        restingHeartRate: 95,
      );
      expect(exhausted.readinessScore, greaterThanOrEqualTo(15));
    });

    test('TC-STA-006: Personal record logging creates new entries or updates existing', () {
      final initialCount = state.prs.length;

      // Add fresh exercise PR
      state.addPersonalRecord('Deadlift', 180.0, 5);
      expect(state.prs.length, initialCount + 1);
      expect(state.prs.first.exercise, 'Deadlift');
      expect(state.prs.first.weight, 180.0);

      // Updating existing PR
      state.addPersonalRecord('Deadlift', 190.0, 5);
      expect(state.prs.length, initialCount + 1);
      expect(state.prs.first.weight, 190.0);
    });

    test('TC-STA-007: resetToDefaults restores state cleanly for test repeatability', () {
      state.logHydration(2.0);
      state.logMeal(calories: 1200, protein: 90, carbs: 120, fats: 30);
      expect(state.waterLiters, 4.5);

      state.resetToDefaults();
      expect(state.waterLiters, 2.5);
      expect(state.caloriesConsumed, 1850);
      expect(state.proteinGrams, 145);
    });
  });
}
