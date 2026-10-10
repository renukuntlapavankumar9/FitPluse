import 'dart:async';
import 'package:flutter/material.dart';

/// Models for FitPulse Core Features

class WorkoutSet {
  final int setNum;
  double weight;
  int reps;
  double rpe; // Rate of Perceived Exertion (1.0 to 10.0)
  bool isCompleted;
  String? notes;

  WorkoutSet({
    required this.setNum,
    required this.weight,
    required this.reps,
    this.rpe = 8.0,
    this.isCompleted = false,
    this.notes,
  });

  /// Auto-calculates Estimated 1-Rep Max using the Epley formula: 1RM = weight * (1 + reps / 30)
  double get estimatedOneRepMax {
    if (reps <= 1) return weight;
    return weight * (1.0 + (reps / 30.0));
  }

  double get volume => weight * reps;
}

class HabitItem {
  final String id;
  String title;
  int streak;
  String category;
  String time;
  String targetValue;
  bool isCompleted;
  DateTime lastCompletedDate;

  HabitItem({
    required this.id,
    required this.title,
    required this.streak,
    required this.category,
    required this.time,
    required this.targetValue,
    this.isCompleted = false,
    DateTime? lastCompletedDate,
  }) : lastCompletedDate = lastCompletedDate ?? DateTime.now();
}

class PersonalRecord {
  final String exercise;
  double weight;
  int reps;
  DateTime dateAchieved;
  String note;

  PersonalRecord({
    required this.exercise,
    required this.weight,
    required this.reps,
    required this.dateAchieved,
    required this.note,
  });

  double get weightKg => weight;
  double get estimatedOneRepMaxKg => weight * (1 + reps / 30.0);
  String get achievedDate =>
      '${dateAchieved.year}-${dateAchieved.month.toString().padLeft(2, '0')}-${dateAchieved.day.toString().padLeft(2, '0')}';
}

class ReadinessMetrics {
  double sleepHours;
  int sorenessLevel; // 1 (None) to 10 (Extreme)
  int energyLevel; // 1 (Exhausted) to 10 (Peak)
  int restingHeartRate; // bpm

  ReadinessMetrics({
    this.sleepHours = 7.5,
    this.sorenessLevel = 3,
    this.energyLevel = 8,
    this.restingHeartRate = 58,
  });

  /// Algorithmic FitPulse Readiness Index (0 - 100%)
  int get readinessScore {
    // Sleep component (up to 40 pts): 8 hours = optimal
    double sleepScore = (sleepHours / 8.0).clamp(0.0, 1.2) * 35.0;
    // Energy component (up to 35 pts): 10 = max
    double energyScore = (energyLevel / 10.0) * 35.0;
    // Soreness penalty (deduct up to 20 pts)
    double sorenessPenalty = (sorenessLevel / 10.0) * 20.0;
    // Heart rate modifier (optimal 50-65 bpm)
    double hrScore = 15.0;
    if (restingHeartRate > 75) {
      hrScore = 5.0;
    } else if (restingHeartRate > 65) {
      hrScore = 10.0;
    }

    int total = (sleepScore + energyScore + hrScore - sorenessPenalty).round();
    return total.clamp(15, 99);
  }

  String get recommendation {
    int score = readinessScore;
    if (score >= 85) return 'Optimal for Peak Intensity & Heavy Loads 🔥';
    if (score >= 70) return 'Solid Recovery: Stick to Scheduled Training 💪';
    if (score >= 50) return 'Moderate Fatigue: Reduce Working Volume by 15% ⚠️';
    return 'High Fatigue: Prioritize Active Recovery & Sleep 🛌';
  }
}

/// Central Reactive State Provider for FitPulse
class FitPulseState extends ChangeNotifier {
  // Singleton pattern for easy global access across features
  static final FitPulseState instance = FitPulseState._internal();
  FitPulseState._internal() {
    _initDefaults();
  }

  // --- 1. Nutrition & Hydration Fast-Logger State ---
  double caloriesConsumed = 1850;
  double caloriesTarget = 2400;
  double proteinGrams = 145;
  double proteinTarget = 160;
  double carbsGrams = 210;
  double carbsTarget = 260;
  double fatsGrams = 55;
  double fatsTarget = 70;
  double waterLiters = 2.5;
  double waterTarget = 3.0;

  // --- 2. Active Workout & Sets State ---
  String currentExercise = 'Barbell Bench Press';
  String currentTargetMuscles = 'Chest • Triceps • Anterior Delts';
  int activeWorkoutSeconds = 1650; // 00:27:30
  bool isTimerRunning = true;
  Timer? _stopwatchTimer;

  // Rest Timer countdown
  int restTimerSeconds = 0;
  int restTimerDuration = 90;
  Timer? _restTimer;

  List<WorkoutSet> activeSets = [];

  // --- 3. Habits State ---
  List<HabitItem> habits = [];

  // --- 4. Personal Records & Historical Analytics State ---
  List<PersonalRecord> personalRecords = [];
  List<Map<String, dynamic>> weeklyVolumeData = [];

  // --- 5. Athlete Readiness & Recovery State ---
  ReadinessMetrics readiness = ReadinessMetrics();

  void _initDefaults() {
    // Initialize default sets
    activeSets = [
      WorkoutSet(setNum: 1, weight: 60.0, reps: 10, rpe: 7.5, isCompleted: true),
      WorkoutSet(setNum: 2, weight: 70.0, reps: 8, rpe: 8.0, isCompleted: true),
      WorkoutSet(setNum: 3, weight: 75.0, reps: 6, rpe: 8.5, isCompleted: false),
      WorkoutSet(setNum: 4, weight: 75.0, reps: 6, rpe: 9.0, isCompleted: false),
    ];

    // Initialize habits
    habits = [
      HabitItem(
        id: '1',
        title: 'Read 20 Pages',
        streak: 5,
        category: 'Mindset',
        time: '07:30 AM',
        targetValue: '20 pages',
        isCompleted: true,
      ),
      HabitItem(
        id: '2',
        title: 'Drink 3L Water',
        streak: 12,
        category: 'Hydration',
        time: 'Throughout Day',
        targetValue: '3.0 Liters',
        isCompleted: true,
      ),
      HabitItem(
        id: '3',
        title: '30 Mins Cardio & Stretching',
        streak: 4,
        category: 'Fitness',
        time: '05:00 PM',
        targetValue: '30 minutes',
        isCompleted: true,
      ),
      HabitItem(
        id: '4',
        title: 'Evening Meditation & Gratitude',
        streak: 0,
        category: 'Wellness',
        time: '09:30 PM',
        targetValue: '10 minutes',
        isCompleted: false,
      ),
      HabitItem(
        id: '5',
        title: 'No Sugar After 8 PM',
        streak: 7,
        category: 'Nutrition',
        time: '08:00 PM',
        targetValue: '100% adherence',
        isCompleted: false,
      ),
    ];

    // Initialize Personal Records
    personalRecords = [
      PersonalRecord(
        exercise: 'Barbell Bench Press',
        weight: 100.0,
        reps: 3,
        dateAchieved: DateTime.now(),
        note: 'New PR Set Today! 🥇 (Estimated 1RM: 110 kg)',
      ),
      PersonalRecord(
        exercise: 'Barbell Back Squat',
        weight: 140.0,
        reps: 5,
        dateAchieved: DateTime.now().subtract(const Duration(days: 3)),
        note: 'Estimated 1RM: 163 kg 🏆',
      ),
      PersonalRecord(
        exercise: 'Conventional Deadlift',
        weight: 180.0,
        reps: 2,
        dateAchieved: DateTime.now().subtract(const Duration(days: 14)),
        note: 'Estimated 1RM: 192 kg 🏆',
      ),
    ];

    // Weekly Volume Data
    weeklyVolumeData = [
      {'day': 'Mon', 'volume': 2400.0, 'workout': 'Chest & Triceps'},
      {'day': 'Tue', 'volume': 1850.0, 'workout': 'Back & Biceps'},
      {'day': 'Wed', 'volume': 0.0, 'workout': 'Rest & Recovery'},
      {'day': 'Thu', 'volume': 3100.0, 'workout': 'Legs & Core'},
      {'day': 'Fri', 'volume': 2600.0, 'workout': 'Shoulders & Arms'},
      {'day': 'Sat', 'volume': 2200.0, 'workout': 'Full Body HIIT'},
      {'day': 'Sun', 'volume': 0.0, 'workout': 'Active Mobility'},
    ];

    // Start workout clock
    _startStopwatch();
  }

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isTimerRunning) {
        activeWorkoutSeconds++;
        notifyListeners();
      }
    });
  }

  void toggleStopwatch() {
    isTimerRunning = !isTimerRunning;
    notifyListeners();
  }

  String formatStopwatch() {
    int hours = activeWorkoutSeconds ~/ 3600;
    int minutes = (activeWorkoutSeconds % 3600) ~/ 60;
    int seconds = activeWorkoutSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- WORKOUT ACTIONS ---

  void addWorkoutSet({
    required double weight,
    required int reps,
    required double rpe,
    String? notes,
  }) {
    final nextNum = activeSets.length + 1;
    final newSet = WorkoutSet(
      setNum: nextNum,
      weight: weight,
      reps: reps,
      rpe: rpe,
      isCompleted: false,
      notes: notes,
    );
    activeSets.add(newSet);
    notifyListeners();
  }

  void toggleSetCompletion(int index) {
    if (index >= 0 && index < activeSets.length) {
      activeSets[index].isCompleted = !activeSets[index].isCompleted;
      if (activeSets[index].isCompleted) {
        // Start rest timer
        startRestTimer(90);

        // Check if new PR was broken
        double setMax = activeSets[index].estimatedOneRepMax;
        var existingPr = personalRecords.firstWhere(
          (p) => p.exercise == currentExercise,
          orElse: () => PersonalRecord(exercise: currentExercise, weight: 0, reps: 0, dateAchieved: DateTime.now(), note: ''),
        );
        if (activeSets[index].weight > existingPr.weight) {
          existingPr.weight = activeSets[index].weight;
          existingPr.reps = activeSets[index].reps;
          existingPr.dateAchieved = DateTime.now();
          existingPr.note = 'New All-Time High! 🔥 (Est 1RM: ${setMax.toStringAsFixed(1)} kg)';
        }

        // Add to weekly volume
        weeklyVolumeData[3]['volume'] = (weeklyVolumeData[3]['volume'] as double) + activeSets[index].volume;
      }
      notifyListeners();
    }
  }

  void startRestTimer(int seconds) {
    _restTimer?.cancel();
    restTimerSeconds = seconds;
    restTimerDuration = seconds;
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (restTimerSeconds > 0) {
        restTimerSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void skipRestTimer() {
    _restTimer?.cancel();
    restTimerSeconds = 0;
    notifyListeners();
  }

  void addRestTime(int extraSeconds) {
    restTimerSeconds += extraSeconds;
    notifyListeners();
  }

  double get totalWorkoutVolume {
    double vol = 0;
    for (var s in activeSets) {
      if (s.isCompleted) vol += s.volume;
    }
    return vol;
  }

  // --- HABIT ACTIONS ---

  void toggleHabit(String id) {
    int idx = habits.indexWhere((h) => h.id == id);
    if (idx != -1) {
      habits[idx].isCompleted = !habits[idx].isCompleted;
      if (habits[idx].isCompleted) {
        habits[idx].streak++;
      } else {
        if (habits[idx].streak > 0) habits[idx].streak--;
      }
      notifyListeners();
    }
  }

  void createHabit({
    required String title,
    required String category,
    required String time,
    required String targetValue,
  }) {
    habits.add(
      HabitItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        streak: 1,
        category: category,
        time: time,
        targetValue: targetValue,
        isCompleted: false,
      ),
    );
    notifyListeners();
  }

  // --- NUTRITION & HYDRATION ACTIONS ---

  void addWater(double liters) {
    waterLiters = (waterLiters + liters).clamp(0.0, 10.0);
    notifyListeners();
  }

  void logHydration(double liters) => addWater(liters);

  void logMeal({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) {
    caloriesConsumed += calories;
    proteinGrams += protein;
    carbsGrams += carbs;
    fatsGrams += fats;
    notifyListeners();
  }

  // --- READINESS ACTIONS ---

  void updateReadiness({
    required double sleepHours,
    required int sorenessLevel,
    required int energyLevel,
    required int restingHeartRate,
  }) {
    readiness.sleepHours = sleepHours;
    readiness.sorenessLevel = sorenessLevel;
    readiness.energyLevel = energyLevel;
    readiness.restingHeartRate = restingHeartRate;
    notifyListeners();
  }

  // --- CONVENIENCE GETTERS & ANALYTICS ---

  double get totalVolumeLiftedKg => totalWorkoutVolume;
  int get workoutDurationSeconds => activeWorkoutSeconds;
  int get completedSetsCount => activeSets.where((s) => s.isCompleted).length;
  List<PersonalRecord> get prs => personalRecords;

  int get habitConsistencyScore {
    if (habits.isEmpty) return 0;
    final completed = habits.where((h) => h.isCompleted).length;
    return ((completed / habits.length) * 100).round();
  }

  void addPersonalRecord(String exercise, double weight, int reps) {
    final est1RM = weight * (1 + reps / 30.0);
    final existingIdx = personalRecords.indexWhere((p) => p.exercise == exercise);
    if (existingIdx != -1) {
      personalRecords[existingIdx].weight = weight;
      personalRecords[existingIdx].reps = reps;
      personalRecords[existingIdx].dateAchieved = DateTime.now();
      personalRecords[existingIdx].note =
          'Updated Record! 🥇 (Estimated 1RM: ${est1RM.toStringAsFixed(1)} kg)';
    } else {
      personalRecords.insert(
        0,
        PersonalRecord(
          exercise: exercise,
          weight: weight,
          reps: reps,
          dateAchieved: DateTime.now(),
          note: 'New PR Logged! 🥇 (Estimated 1RM: ${est1RM.toStringAsFixed(1)} kg)',
        ),
      );
    }
    notifyListeners();
  }

  /// Resets state to baseline default values (essential for test suite isolation)
  void resetToDefaults() {
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    isTimerRunning = false;
    activeWorkoutSeconds = 1650;
    restTimerSeconds = 0;
    caloriesConsumed = 1850;
    caloriesTarget = 2400;
    proteinGrams = 145;
    proteinTarget = 160;
    carbsGrams = 210;
    carbsTarget = 260;
    fatsGrams = 55;
    fatsTarget = 70;
    waterLiters = 2.5;
    waterTarget = 3.0;
    currentExercise = 'Barbell Bench Press';
    _initDefaults();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}
