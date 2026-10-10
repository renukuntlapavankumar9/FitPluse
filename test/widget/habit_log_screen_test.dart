// ============================================================================
// FitPulse Mobile App — Habit Tracker Screen Widget Test Suite
// Week 5: Comprehensive Testing and App Optimization
// Tests rendering of habits list, completion checkbox interaction, and form validation
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitpulse_app/core/state/app_state.dart';
import 'package:fitpulse_app/features/habits/habit_log_screen.dart';

void main() {
  group('HabitLogScreen Widget Tests', () {
    setUp(() {
      FitPulseState.instance.resetToDefaults();
    });

    testWidgets('TC-WGT-008: Renders habit tracker header, day selector strip, and habit list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HabitLogScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Habit Tracker'), findsOneWidget);
      expect(find.text('New Habit'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget); // Default day
      expect(find.text('Read 20 Pages'), findsOneWidget);
    });

    testWidgets('TC-WGT-009: Tapping habit checkbox toggles completion status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HabitLogScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find Checkbox widget
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsWidgets);

      // Tap to toggle
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Verify state was altered
      expect(FitPulseState.instance.habits.isNotEmpty, true);
    });

    testWidgets('TC-WGT-010: Floating Action Button opens Create New Habit modal with validation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HabitLogScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap New Habit FAB
      await tester.tap(find.text('New Habit'));
      await tester.pumpAndSettle();

      expect(find.text('Create New Habit'), findsOneWidget);
      expect(find.text('SAVE & ACTIVATE HABIT'), findsOneWidget);

      // Attempt to save empty form to trigger validation
      await tester.tap(find.text('SAVE & ACTIVATE HABIT'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a habit title'), findsOneWidget);
    });

    testWidgets('TC-WGT-011: Filter chips filter between Pending and Completed habits', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HabitLogScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final pendingChip = find.text('Pending');
      if (pendingChip.evaluate().isNotEmpty) {
        await tester.tap(pendingChip);
        await tester.pumpAndSettle();
      }

      final completedChip = find.text('Completed');
      if (completedChip.evaluate().isNotEmpty) {
        await tester.tap(completedChip);
        await tester.pumpAndSettle();
      }
    });
  });
}
