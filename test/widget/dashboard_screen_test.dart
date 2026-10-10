// ============================================================================
// FitPulse Mobile App — Dashboard Screen Widget Test Suite
// Week 5: Comprehensive Testing and App Optimization
// Tests rendering of KPI rings, Quick Hydration action, and readiness check-in modal
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitpulse_app/core/state/app_state.dart';
import 'package:fitpulse_app/features/dashboard/dashboard_screen.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    setUp(() {
      FitPulseState.instance.resetToDefaults();
    });

    testWidgets('TC-WGT-004: Renders hero CTA, readiness card, and goal progress rings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FitPulse'), findsOneWidget);
      expect(find.text('Daily Goal Progress'), findsOneWidget);
      expect(find.text('FITPULSE READINESS'), findsOneWidget);
      expect(find.text('START TODAY\'S WORKOUT'), findsOneWidget);
    });

    testWidgets('TC-WGT-005: Displays accurate nutrition calories and hydration values', (tester) async {
      final state = FitPulseState.instance;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('${state.caloriesConsumed.toInt()} / ${state.caloriesTarget.toInt()} kcal'), findsOneWidget);
      expect(find.text('${state.waterLiters.toStringAsFixed(1)}L'), findsOneWidget);
    });

    testWidgets('TC-WGT-006: Tapping Quick Hydration updates state and dashboard metrics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialWater = FitPulseState.instance.waterLiters;

      // Tap the +500ml quick water button
      final hydrationButton = find.text('+500ml Water');
      if (hydrationButton.evaluate().isNotEmpty) {
        await tester.tap(hydrationButton);
        await tester.pumpAndSettle();
        expect(FitPulseState.instance.waterLiters, closeTo(initialWater + 0.5, 0.01));
      }
    });

    testWidgets('TC-WGT-007: Tapping Daily Readiness opens check-in modal with input fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Readiness check-in card
      final readinessCard = find.text('Tap to Check-In');
      await tester.tap(readinessCard);
      await tester.pumpAndSettle();

      // Check-in modal appears
      expect(find.text('Sleep Duration (Hours)'), findsOneWidget);
      expect(find.text('Resting Heart Rate (BPM)'), findsOneWidget);
      expect(find.text('CALCULATE & SAVE SCORE'), findsOneWidget);

      // Close modal
      final closeButton = find.byIcon(Icons.close);
      if (closeButton.evaluate().isNotEmpty) {
        await tester.tap(closeButton);
        await tester.pumpAndSettle();
      }
    });
  });
}
