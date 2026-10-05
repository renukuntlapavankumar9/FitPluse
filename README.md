# FitPulse — Smart Strength & Habit Ecosystem (Week 3 Submission)

[![Framework](https://img.shields.io/badge/Framework-Flutter_3.29-02569B?logo=flutter)]()
[![Language](https://img.shields.io/badge/Language-Dart_3.7-0175C2?logo=dart)]()
[![Design](https://img.shields.io/badge/Design-Material_3-7C3AED)]()
[![Package](https://img.shields.io/badge/Application_ID-com.fitpulse.app-1E3A8A)]()
[![Status](https://img.shields.io/badge/Build-Passing_(0_Lints)-16A34A)]()

**FitPulse** (`com.fitpulse.app`) is a high-performance, modular Flutter mobile application built for the **Yuva Intern Mobile Application Development Track**. Building upon the foundational UI prototype from Week 2, **Week 3** delivers complete interactive core functionality, reactive state management, strict form validation, algorithmic recovery tracking, and comprehensive hardware-verified bug fixing.

---

## 🚀 Top 5 Flagship Features (What Makes FitPulse Stand Out)

FitPulse is engineered to outperform generic fitness trackers by combining exercise science algorithms with friction-free athlete logging:

1. **🏋️‍♂️ Interactive Set & Volume Logger with Real-Time Epley 1RM Preview**
   - Athletes can dynamically log sets with rigorous input validation: Weight (1–600 kg), Repetitions (1–100), and RPE intensity (1.0–10.0).
   - Real-time reactive preview of theoretical 1-Rep Max via the scientific **Epley Formula**:
     $$\text{1RM} = W \times \left(1 + \frac{R}{30}\right)$$
   - Logging a set automatically launches an **Intelligent Rest Timer Bar** with real-time countdown, quick `+30s` extension, and `Skip` controls, while dynamically recalculating total workout volume.

2. **✅ Dynamic Habit Forge with Multi-Category Tagging & Streak Analytics**
   - Dedicated routine builder with strict title validation, measurable target metrics, and 5 wellness categories (*Fitness, Hydration, Nutrition, Mindset, Wellness*).
   - Instant checkbox event handling, interactive filter chips (*All, Pending, Completed*), dynamic streak tracking, and live consistency score recalculation.

3. **🥗 Macro & Caloric Fast-Logger with One-Tap Hydration Tracking**
   - Modal dialog with multi-input boundary validation for Calories, Protein, Carbs, and Fats to update athlete fueling goals.
   - One-tap quick hydration actions (`+250ml`, `+500ml`) with live progress rings and dynamic percentage recalculations.

4. **🎯 Multi-Formula 1-Rep Max Calculator & Dynamic PR Tracking**
   - Algorithmic strength tool comparing three scientific formulas:
     - **Epley Formula:** $W \times (1 + R / 30)$
     - **Brzycki Formula:** $W \times \frac{36}{37 - R}$
     - **Lombardi Formula:** $W \times R^{0.10}$
   - Computes tailored training intensity zones (95% Power, 85% Strength, 75% Hypertrophy).
   - Single-tap **"Save as Personal Record"** button that dynamically syncs new PR records across all app views in real-time.

5. **🔋 Algorithmic Athlete Readiness & Recovery Check-In**
   - Physiological check-in tracking sleep duration (hours), muscle soreness (1–10 slider), perceived energy (1–10 slider), and resting heart rate (bpm).
   - Computes an overall **FitPulse Readiness Index (0–100%)** with personalized recommendations for training volume auto-regulation.

---

## 🏗️ Project Architecture & File Layout

The codebase strictly adheres to a **Feature-First Architecture** coupled with centralized reactive state management:

```text
fitpulse_app/
├── lib/
│   ├── main.dart                          # App entry point & theme initialization
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_colors.dart            # Design tokens & Material 3 color palette
│   │   ├── theme/
│   │   │   └── app_theme.dart             # App-wide Material 3 theme configuration
│   │   └── state/
│   │       └── app_state.dart             # Central ChangeNotifier (FitPulseState singleton)
│   ├── navigation/
│   │   └── main_navigation_shell.dart     # IndexedStack bottom navigation (zero re-render)
│   └── features/
│       ├── dashboard/
│       │   └── dashboard_screen.dart      # Readiness card, macro rings, habits, quick actions
│       ├── workout/
│       │   └── workout_tracker_screen.dart# Stopwatch, live rest timer, set logger modal
│       ├── habits/
│       │   └── habit_log_screen.dart      # Calendar strip, filter chips, Habit Forge modal
│       ├── analytics/
│       │   └── analytics_screen.dart      # Volume bar charts, 1RM multi-formula tool, PR list
│       └── profile/
│           └── profile_screen.dart        # Athlete bio, target splits, settings & data export
├── screenshots/
│   └── week3/                             # 17 device-verified feature screenshots
├── generate_report.py                     # ReportLab script generating the submission PDF
├── Week3_Troubleshooting_and_Bug_Report.pdf# Official technical PDF report
├── pubspec.yaml
└── README.md
```

---

## 🔧 State Management & Event Handling Architecture

- **Single Source of Truth:** `FitPulseState.instance` (`ChangeNotifier`) houses all mutable state.
- **Selective Reactive Rebuilds:** Presentation screens subscribe via `ListenableBuilder` or state lifecycle listeners (`addListener` / `removeListener`), ensuring efficient 60fps UI performance without redundant re-renders.
- **Cross-Screen Event Propagation:** 
  - Completing a set on the **Workout Tracker** instantly updates the **Total Volume Lifted** metric and **Personal Record list** on the **Analytics** screen.
  - Toggling a habit on the **Habits** screen instantly recalculates the **Consistency Score** on both the **Dashboard** and **Analytics** screens.

---

## 🛠️ Testing, Debugging & Bug Resolutions

A comprehensive **Troubleshooting & Bug Report** has been compiled in PDF format: [`Week3_Troubleshooting_and_Bug_Report.pdf`](Week3_Troubleshooting_and_Bug_Report.pdf).

### Summary of Defects Diagnosed & Fixed:

| Bug ID | Severity | Description | Diagnostic Tool | Permanent Resolution |
| :--- | :--- | :--- | :--- | :--- |
| **BUG-01** | `MEDIUM` | **RenderFlex Right Overflow (8.7 px):** Quick action button row overflowed on physical device due to font scaling. | Flutter DevTools & Screencap | Wrapped button label in `Flexible(child: Text(..., overflow: TextOverflow.ellipsis))` and adjusted padding. |
| **BUG-02** | `HIGH` | **PR Card Horizontal Squeeze:** Long record strings compressed exercise titles into single-letter vertical text (`B a r b e l l...`). | Physical Device Screencap | Refactored `_buildPrCard` to a 2-tier responsive layout separating title badge from the estimated 1RM chip. |
| **BUG-03** | `HIGH` | **Duplicate Manifest Label Conflict:** Gradle build failed due to `android:label` duplicate declaration during namespace migration to `com.fitpulse.app`. | Gradle Console Output | Reconciled `build.gradle` and `AndroidManifest.xml` namespace and cleaned duplicate attributes. |
| **BUG-04** | `MEDIUM` | **Uncancelled Timer Stacking:** Overlapping rest timer instances ticked at 2x/3x rates after repeated set completions. | ADB Logcat & Console Trace | Encapsulated all timers inside `FitPulseState` with explicit `.cancel()` guards before re-spawning. |
| **BUG-05** | `LOW` | **Flutter 3.29 Deprecation Warnings:** Deprecated `.withOpacity()` and legacy `ThemeData` properties. | `flutter analyze` | Migrated colors to modern `.withValues(alpha: ...)` and updated Material 3 theme properties. |

### Static Analysis Gate:
```bash
flutter analyze
# Output: Analyzing fitpulse_app... No issues found! (0 errors, 0 warnings)
```

---

## 📱 Hardware Verification & Screenshots

All core interactive features were verified on a physical **TECNO LH8n** device (Android 14, 1080×2460 resolution):

| Screenshot | Description |
| :--- | :--- |
| [`01_dashboard_live.png`](screenshots/week3/01_dashboard_live.png) | Live Dashboard with dynamic readiness badge, progress rings, and scheduled workout. |
| [`02_readiness_modal.png`](screenshots/week3/02_readiness_modal.png) | Feature 5: Athlete Readiness check-in modal with sliders and resting heart rate input. |
| [`03_dashboard_macros_fixed.png`](screenshots/week3/03_dashboard_macros_fixed.png) | Macro fueling section and quick actions with resolved layout overflow. |
| [`04_meal_logger_modal.png`](screenshots/week3/04_meal_logger_modal.png) | Feature 3: Macro & Caloric fast-logger dialog. |
| [`05_meal_validation_error.png`](screenshots/week3/05_meal_validation_error.png) | Form validation enforcing required calories and macro gram inputs. |
| [`06_workout_tracker_live.png`](screenshots/week3/06_workout_tracker_live.png) | Feature 1: Active workout tracker with running stopwatch and interactive set log. |
| [`07_workout_add_set_modal.png`](screenshots/week3/07_workout_add_set_modal.png) | Set logger modal with dynamic real-time Epley 1RM calculation preview. |
| [`10_habit_tracker_live.png`](screenshots/week3/10_habit_tracker_live.png) | Feature 2: Weekly calendar strip, habit checklist, filter chips, and consistency streak. |
| [`11_habit_forge_modal.png`](screenshots/week3/11_habit_forge_modal.png) | Habit creation modal with category selector and goal metric definition. |
| [`12_habit_validation_error.png`](screenshots/week3/12_habit_validation_error.png) | Habit form validation rejecting empty submissions with red error labels. |
| [`13_analytics_screen_live.png`](screenshots/week3/13_analytics_screen_live.png) | Weekly volume bar charts and dynamic cross-screen volume recalculation. |
| [`14_analytics_pr_cards_fixed.png`](screenshots/week3/14_analytics_pr_cards_fixed.png) | Feature 4: 1RM tool trigger and responsive personal records list. |
| [`15_1rm_calculator_modal.png`](screenshots/week3/15_1rm_calculator_modal.png) | Scientific multi-formula strength calculator comparing Epley, Brzycki, and Lombardi models. |
| [`16_1rm_saved_pr_snackbar.png`](screenshots/week3/16_1rm_saved_pr_snackbar.png) | Live PR update confirmation and reactive cross-screen list refresh. |
| [`17_profile_screen_live.png`](screenshots/week3/17_profile_screen_live.png) | Athlete profile, streak records, biometric targets, and version v2.0.0. |

---

## ⚡ How to Run the Project Locally

### Prerequisites
- **Flutter SDK:** Version >= 3.29.0
- **Dart SDK:** Version >= 3.7.0
- **Android Studio / VS Code:** Configured with Flutter extension
- Connected Android Device or Emulator

### Execution Steps
1. **Clone or Extract the Project:**
   ```powershell
   cd C:\Projects\Yuvaintern\fitpulse_app
   ```
2. **Fetch Dependencies:**
   ```powershell
   flutter pub get
   ```
3. **Verify Static Code Quality:**
   ```powershell
   flutter analyze
   ```
4. **Launch on Connected Device/Emulator:**
   ```powershell
   flutter run
   ```

---

## 📦 Submission Deliverables Check

- [x] **Source Code ZIP:** `Week3_Core_Features_FitPulse.zip` containing clean source files (post `flutter clean`).
- [x] **Troubleshooting Report (PDF):** `Week3_Troubleshooting_and_Bug_Report.pdf` detailing features, diagnostic tools, and RCAs.
- [x] **Interactive Core Features:** 5 standalone flagship features with strict form validation and real-time event updates.
- [x] **Screenshots:** 17 high-resolution running captures in `screenshots/week3/`.
- [x] **Zero Lints / Zero Warnings:** 100% verified passing with `flutter analyze`.