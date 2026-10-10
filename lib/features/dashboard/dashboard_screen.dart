import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../nutrition_api/food_search_screen.dart';
import '../nutrition_api/weather_advisor_card.dart';

/// Dashboard Screen — Core Hub with Dynamic Recovery Score, Calorie Rings & Fast-Logger
class DashboardScreen extends StatelessWidget {
  final VoidCallback? onStartWorkout;

  const DashboardScreen({super.key, this.onStartWorkout});

  void _showReadinessModal(BuildContext context) {
    final state = FitPulseState.instance;
    final sleepController = TextEditingController(text: state.readiness.sleepHours.toString());
    final rhrController = TextEditingController(text: state.readiness.restingHeartRate.toString());
    double soreness = state.readiness.sorenessLevel.toDouble();
    double energy = state.readiness.energyLevel.toDouble();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.monitor_heart, color: AppColors.energyOrange, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Daily Readiness Check-In',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      const Text(
                        'Tune your daily training recommendations based on physiological recovery signals.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      // Sleep Hours Input
                      TextFormField(
                        controller: sleepController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Sleep Duration (Hours)',
                          hintText: 'e.g. 7.5',
                          prefixIcon: const Icon(Icons.bedtime_outlined),
                          filled: true,
                          fillColor: AppColors.cardSubtle,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter sleep duration';
                          final val = double.tryParse(value);
                          if (val == null || val <= 0 || val > 24) return 'Enter a valid duration between 1 and 24 hours';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      // Resting Heart Rate Input
                      TextFormField(
                        controller: rhrController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Resting Heart Rate (BPM)',
                          hintText: 'e.g. 58',
                          prefixIcon: const Icon(Icons.favorite_outline),
                          filled: true,
                          fillColor: AppColors.cardSubtle,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter resting heart rate';
                          final val = int.tryParse(value);
                          if (val == null || val < 35 || val > 140) return 'Enter valid BPM between 35 and 140';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Muscle Soreness Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Muscle Soreness', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${soreness.toInt()} / 10', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      Slider(
                        value: soreness,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: AppColors.energyOrange,
                        onChanged: (val) => setModalState(() => soreness = val),
                      ),
                      // Energy Level Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Perceived Energy Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${energy.toInt()} / 10', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                        ],
                      ),
                      Slider(
                        value: energy,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: AppColors.success,
                        onChanged: (val) => setModalState(() => energy = val),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              state.updateReadiness(
                                sleepHours: double.parse(sleepController.text.trim()),
                                sorenessLevel: soreness.toInt(),
                                energyLevel: energy.toInt(),
                                restingHeartRate: int.parse(rhrController.text.trim()),
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Readiness Score Updated: ${state.readiness.readinessScore}% 🔥'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: const Text('CALCULATE & SAVE SCORE', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLogMealModal(BuildContext context) {
    final state = FitPulseState.instance;
    final calController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.restaurant, color: AppColors.accent, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Log Meal & Macros',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Text('Enter nutrition data to update your daily calorie and macro goals in real-time.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: calController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Calories (kcal)',
                      hintText: 'e.g. 550',
                      prefixIcon: const Icon(Icons.local_fire_department, color: AppColors.energyOrange),
                      filled: true,
                      fillColor: AppColors.cardSubtle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter calories';
                      final num = double.tryParse(val);
                      if (num == null || num <= 0 || num > 4000) return 'Enter realistic calories (1-4000)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: proteinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Protein (g)',
                            hintText: '35',
                            filled: true,
                            fillColor: AppColors.cardSubtle,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (val) => val == null || double.tryParse(val) == null ? 'Enter grams' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: carbsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Carbs (g)',
                            hintText: '50',
                            filled: true,
                            fillColor: AppColors.cardSubtle,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (val) => val == null || double.tryParse(val) == null ? 'Enter grams' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: fatsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Fats (g)',
                            hintText: '15',
                            filled: true,
                            fillColor: AppColors.cardSubtle,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (val) => val == null || double.tryParse(val) == null ? 'Enter grams' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          state.logMeal(
                            calories: double.parse(calController.text.trim()),
                            protein: double.parse(proteinController.text.trim()),
                            carbs: double.parse(carbsController.text.trim()),
                            fats: double.parse(fatsController.text.trim()),
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Logged ${calController.text.trim()} kcal! Progress ring updated 🍎'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text('SUBMIT MEAL ENTRY', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = FitPulseState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final calPercent = (state.caloriesConsumed / state.caloriesTarget).clamp(0.0, 1.0);
        final readiness = state.readiness;
        final completedHabits = state.habits.where((h) => h.isCompleted).length;

        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FitPulse',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.4),
                ),
                Text(
                  'Good morning, Alex 👋',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.energyLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.energyOrange.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department, color: AppColors.energyOrange, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '7 Days',
                      style: TextStyle(color: AppColors.energyOrange, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TOP FEATURE 5: ATHLETE READINESS & RECOVERY CARD ---
                GestureDetector(
                  onTap: () => _showReadinessModal(context),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          readiness.readinessScore >= 80 ? const Color(0xFF064E3B) : const Color(0xFF1E293B),
                          readiness.readinessScore >= 80 ? const Color(0xFF047857) : const Color(0xFF334155),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: CircularProgressIndicator(
                                value: readiness.readinessScore / 100.0,
                                strokeWidth: 5,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  readiness.readinessScore >= 80 ? AppColors.success : Colors.amber,
                                ),
                              ),
                            ),
                            Text(
                              '${readiness.readinessScore}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('FITPULSE READINESS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('Tap to Check-In', style: TextStyle(color: Colors.white, fontSize: 9)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                readiness.recommendation,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const RepaintBoundary(child: WeatherAdvisorCard()),
                const SizedBox(height: 16),

                // --- TOP FEATURE 3: DAILY GOAL PROGRESS RINGS & NUTRITION ---
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(color: Color(0x060F172A), blurRadius: 12, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daily Goal Progress',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                            child: const Text('TODAY', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      RepaintBoundary(
                        child: Stack(
                          alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 140,
                            width: 140,
                            child: CircularProgressIndicator(
                              value: calPercent,
                              strokeWidth: 12,
                              strokeCap: StrokeCap.round,
                              backgroundColor: AppColors.cardSubtle,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(calPercent * 100).toInt()}%',
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${state.caloriesConsumed.toInt()} / ${state.caloriesTarget.toInt()} kcal',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricMini(Icons.local_fire_department, AppColors.energyOrange, '${state.caloriesConsumed.toInt()}', 'Burned kcal'),
                          Container(width: 1, height: 28, color: AppColors.border),
                          _buildMetricMini(Icons.timer_outlined, AppColors.accent, '${state.activeWorkoutSeconds ~/ 60} min', 'Active Time'),
                          Container(width: 1, height: 28, color: AppColors.border),
                          _buildMetricMini(Icons.water_drop_outlined, Colors.cyan, '${state.waterLiters.toStringAsFixed(1)}L', 'Hydration'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Hero Workout CTA Card
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onStartWorkout,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt, color: Colors.amber, size: 14),
                                      SizedBox(width: 4),
                                      Text('SCHEDULED TODAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                                    ],
                                  ),
                                ),
                                const Text('Day 3 of 5', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.currentExercise,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.currentTargetMuscles,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 44,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 22),
                                  SizedBox(width: 6),
                                  Text("START TODAY'S WORKOUT", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.3)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive Quick Actions with Validation
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.water_drop_outlined,
                        label: '+250ml Water',
                        color: Colors.cyan,
                        onTap: () {
                          state.addWater(0.25);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added 250ml water! Total: ${state.waterLiters.toStringAsFixed(2)}L 💧'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.fastfood_outlined,
                        label: 'Log Meal / Macros',
                        color: AppColors.accent,
                        onTap: () => _showLogMealModal(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- PUBLIC REST API INTEGRATION: SEARCH OPEN FOOD FACTS DATABASE ---
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FoodSearchScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.cloud_sync, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Search Food & Nutrition API',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(Icons.bolt, color: Colors.amber, size: 14),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Live Open Food Facts Database • Custom Serving Scaler',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Dynamic Habit Checklist
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Today's Habits", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text(
                      '$completedHabits of ${state.habits.length} Done',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: completedHabits == state.habits.length ? AppColors.success : AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(state.habits.length, (index) {
                  final habit = state.habits[index];
                  return _buildHabitItem(
                    context: context,
                    id: habit.id,
                    title: habit.title,
                    subtitle: '${habit.category} • Target: ${habit.targetValue}',
                    isDone: habit.isCompleted,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricMini(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitItem({
    required BuildContext context,
    required String id,
    required String title,
    required String subtitle,
    required bool isDone,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF0FDF4) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDone ? AppColors.success.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FitPulseState.instance.toggleHabit(id);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isDone ? 'Marked "$title" as pending' : 'Marked "$title" as completed! 🎉'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: isDone ? AppColors.success : AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 11, color: isDone ? AppColors.success : AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Done', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
