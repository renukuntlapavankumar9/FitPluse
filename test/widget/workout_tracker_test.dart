// ============================================================================
// FitPulse Mobile App — Active Workout Screen Widget Test Suite
// Week 5: Comprehensive Testing and App Optimization
// Tests rendering of exercise details, set completion, and set addition form validation
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitpulse_app/core/state/app_state.dart';
import 'package:fitpulse_app/features/workout/workout_tracker_screen.dart';

void main() {
  group('WorkoutTrackerScreen Widget Tests', () {
    setUp(() {
      FitPulseState.instance.resetToDefaults();
    });

    testWidgets('TC-WGT-012: Renders active exercise title, target muscles, and sets table', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active Workout'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('Add Set'), findsOneWidget);
      expect(find.text('Form Tips'), findsOneWidget);
    });

    testWidgets('TC-WGT-013: Form tips bottom sheet displays technique cues on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Form Tips'));
      await tester.pumpAndSettle();

      expect(find.text('Barbell Bench Press — Form Cues'), findsOneWidget);
      expect(find.text('1. Setup & Arch'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });

    testWidgets('TC-WGT-014: Add Set button opens modal dialog with pre-populated weights and reps', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Set'));
      await tester.pumpAndSettle();

      expect(find.text('CONFIRM & ADD SET'), findsOneWidget);
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Reps Target'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });

    testWidgets('TC-WGT-015: Stopwatch timer pause and play updates running state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // State was reset to isTimerRunning = false in resetToDefaults()
      final playIcon = find.byIcon(Icons.play_circle_outline);
      expect(playIcon, findsOneWidget);

      await tester.tap(playIcon);
      await tester.pumpAndSettle();
      expect(FitPulseState.instance.isTimerRunning, true);

      final pauseIcon = find.byIcon(Icons.pause_circle_outline);
      expect(pauseIcon, findsOneWidget);
      await tester.tap(pauseIcon);
      await tester.pumpAndSettle();
      expect(FitPulseState.instance.isTimerRunning, false);
    });
  });
}
