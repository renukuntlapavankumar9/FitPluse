import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';

/// Active Workout Screen — Interactive Set Logger with Validation, Auto-1RM & Live Rest Timer
class WorkoutTrackerScreen extends StatefulWidget {
  const WorkoutTrackerScreen({super.key});

  @override
  State<WorkoutTrackerScreen> createState() => _WorkoutTrackerScreenState();
}

class _WorkoutTrackerScreenState extends State<WorkoutTrackerScreen> {
  final _formKey = GlobalKey<FormState>();

  void _showAddSetDialog(BuildContext context) {
    final state = FitPulseState.instance;
    final lastSet = state.activeSets.isNotEmpty ? state.activeSets.last : null;
    final defaultWeight = lastSet != null ? lastSet.weight.toString() : '60';
    final defaultReps = lastSet != null ? lastSet.reps.toString() : '10';
    final defaultRpe = lastSet != null ? lastSet.rpe.toString() : '8.0';

    final weightController = TextEditingController(text: defaultWeight);
    final repsController = TextEditingController(text: defaultReps);
    final rpeController = TextEditingController(text: defaultRpe);
    final notesController = TextEditingController();

    double previewOneRm = lastSet?.estimatedOneRepMax ?? 80.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void updatePreview() {
              final w = double.tryParse(weightController.text) ?? 0;
              final r = int.tryParse(repsController.text) ?? 0;
              if (w > 0 && r > 0) {
                setModalState(() {
                  previewOneRm = r <= 1 ? w : w * (1.0 + (r / 30.0));
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Log Set #${state.activeSets.length + 1}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      const Text(
                        'Record exact load, reps, and perceived intensity with automatic 1RM calculation.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      // 1RM Live Calculation Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calculate_outlined, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text('Estimated 1-Rep Max (1RM):', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                            Text(
                              '${previewOneRm.toStringAsFixed(1)} kg',
                              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: weightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Weight (kg)',
                                hintText: 'e.g. 70.0',
                                prefixIcon: const Icon(Icons.fitness_center),
                                filled: true,
                                fillColor: AppColors.cardSubtle,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (_) => updatePreview(),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter weight';
                                final num = double.tryParse(val);
                                if (num == null || num <= 0 || num > 500) return 'Invalid (1-500kg)';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: repsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Reps Target',
                                hintText: 'e.g. 8',
                                prefixIcon: const Icon(Icons.repeat),
                                filled: true,
                                fillColor: AppColors.cardSubtle,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (_) => updatePreview(),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter reps';
                                final num = int.tryParse(val);
                                if (num == null || num <= 0 || num > 100) return 'Invalid (1-100)';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: rpeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Intensity (RPE 1-10)',
                                hintText: 'e.g. 8.5',
                                prefixIcon: const Icon(Icons.speed),
                                filled: true,
                                fillColor: AppColors.cardSubtle,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter RPE';
                                final num = double.tryParse(val);
                                if (num == null || num < 1.0 || num > 10.0) return 'RPE 1 to 10';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: notesController,
                              decoration: InputDecoration(
                                labelText: 'Notes (optional)',
                                hintText: 'e.g. paused reps',
                                filled: true,
                                fillColor: AppColors.cardSubtle,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
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
                            if (_formKey.currentState!.validate()) {
                              state.addWorkoutSet(
                                weight: double.parse(weightController.text.trim()),
                                reps: int.parse(repsController.text.trim()),
                                rpe: double.parse(rpeController.text.trim()),
                                notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Set #${state.activeSets.length} added! Est 1RM: ${previewOneRm.toStringAsFixed(1)} kg'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: const Text('CONFIRM & ADD SET', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showFormTipsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Barbell Bench Press — Form Cues', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              _buildFormCueItem('1. Setup & Arch', 'Retract and depress shoulder blades into the bench. Maintain natural lumbar arch.'),
              _buildFormCueItem('2. Grip & Elbows', 'Grip bar slightly wider than shoulder width. Tuck elbows at roughly 45-60 degrees.'),
              _buildFormCueItem('3. Bar Path & Drive', 'Lower bar with control to lower sternum. Drive heels through floor to engage leg drive.'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormCueItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = FitPulseState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final completedSetsCount = state.activeSets.where((s) => s.isCompleted).length;
        final hasActiveRest = state.restTimerSeconds > 0;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: state.isTimerRunning ? AppColors.success : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Active Workout'),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () => state.toggleStopwatch(),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.isTimerRunning ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.formatStopwatch(),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Spotlight & Form Tips
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1F0F172A), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'EXERCISE 1 OF 4',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showFormTipsDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.info_outline, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('Form Tips', style: TextStyle(color: Colors.white, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.fitness_center, color: AppColors.accent, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.currentExercise,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  state.currentTargetMuscles,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: state.activeSets.isNotEmpty ? completedSetsCount / state.activeSets.length : 0,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Sets Header & Add Set Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Sets ($completedSetsCount/${state.activeSets.length} Completed)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddSetDialog(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.add, size: 16, color: AppColors.accent),
                      label: const Text('Add Set', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Sets List with Interactive Toggle
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.activeSets.length,
                    itemBuilder: (context, index) {
                      final set = state.activeSets[index];
                      final isDone = set.isCompleted;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDone ? const Color(0xFFF8FAFC) : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDone ? AppColors.success.withValues(alpha: 0.3) : AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: isDone ? AppColors.success : AppColors.primaryLight,
                            child: Text(
                              '${set.setNum}',
                              style: TextStyle(
                                color: isDone ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            'Set ${set.setNum}: ${set.weight} kg × ${set.reps} reps (RPE ${set.rpe})',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Volume: ${(set.volume).toInt()} kg • 1RM Est: ${set.estimatedOneRepMax.toStringAsFixed(1)} kg',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isDone ? AppColors.success : AppColors.textSecondary,
                              size: 26,
                            ),
                            onPressed: () => state.toggleSetCompletion(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // --- TOP FEATURE: INTERACTIVE REST TIMER BAR ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: hasActiveRest ? const Color(0xFFEFF6FF) : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: hasActiveRest ? AppColors.accent : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_bottom_rounded,
                        size: 20,
                        color: hasActiveRest ? AppColors.energyOrange : AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasActiveRest
                              ? 'Rest Timer: ${state.restTimerSeconds}s remaining'
                              : 'Recommended Rest: 90s between sets',
                          style: TextStyle(
                            color: hasActiveRest ? AppColors.energyOrange : AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasActiveRest) ...[
                        GestureDetector(
                          onTap: () => state.addRestTime(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                            child: const Text('+30s', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => state.skipRestTimer(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                            child: const Text('Skip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Full-Width Ergonomic Action
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final pendingIdx = state.activeSets.indexWhere((s) => !s.isCompleted);
                      if (pendingIdx != -1) {
                        state.toggleSetCompletion(pendingIdx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Set #${pendingIdx + 1} logged! 90s rest timer started ⏱️'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('All sets complete! Total Volume: ${state.totalWorkoutVolume.toInt()} kg 🏆'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'LOG COMPLETED SET',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
