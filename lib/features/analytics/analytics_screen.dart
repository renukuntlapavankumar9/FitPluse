import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';

/// Analytics Screen — Volume tracking, performance bar charts, interactive 1RM calculator, and personal records
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year
  int _selectedBarIndex = 3; // Defaults to Thursday

  final List<String> _periods = ['Week', 'Month', 'Year'];

  @override
  void initState() {
    super.initState();
    FitPulseState.instance.addListener(_onStateChange);
  }

  @override
  void dispose() {
    FitPulseState.instance.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  final List<Map<String, dynamic>> _weeklyData = [
    {'day': 'Mon', 'volume': 2400, 'workout': 'Chest & Triceps'},
    {'day': 'Tue', 'volume': 1850, 'workout': 'Back & Biceps'},
    {'day': 'Wed', 'volume': 0, 'workout': 'Rest & Recovery'},
    {'day': 'Thu', 'volume': 3100, 'workout': 'Legs & Core'},
    {'day': 'Fri', 'volume': 2600, 'workout': 'Shoulders & Arms'},
    {'day': 'Sat', 'volume': 2200, 'workout': 'Full Body HIIT'},
    {'day': 'Sun', 'volume': 0, 'workout': 'Active Mobility'},
  ];

  @override
  Widget build(BuildContext context) {
    const double maxVolume = 3500;
    final activeData = _weeklyData[_selectedBarIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting Weekly Performance Report...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Segmented Filter
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: List.generate(_periods.length, (index) {
                  final isSelected = _selectedPeriod == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPeriod = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: isSelected
                              ? [
                                  const BoxShadow(
                                    color: Color(0x0F0F172A),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          _periods[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Volume Lifted Chart Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x060F172A),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Volume Lifted (kg)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '12,150 kg Total this week',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: AppColors.success,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '+12.4%',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Selected Bar Info Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${activeData['day']} (${activeData['workout']})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${activeData['volume']} kg',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Custom Bar Chart
                  SizedBox(
                    height: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(_weeklyData.length, (index) {
                        final item = _weeklyData[index];
                        final vol = (item['volume'] as int).toDouble();
                        final isSelected = _selectedBarIndex == index;
                        final barHeight = vol > 0
                            ? (vol / maxVolume) * 120
                            : 4.0;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBarIndex = index;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (vol > 0)
                                Text(
                                  '${(vol / 1000).toStringAsFixed(1)}k',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppColors.textMuted,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 24,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: isSelected
                                        ? [AppColors.accent, AppColors.primary]
                                        : (vol > 0
                                              ? [
                                                  AppColors.accent.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                  AppColors.accent.withValues(
                                                    alpha: 0.8,
                                                  ),
                                                ]
                                              : [
                                                  AppColors.cardSubtle,
                                                  AppColors.cardSubtle,
                                                ]),
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['day'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Performance Metrics Summary 2x2 Grid (Connected dynamically to FitPulseState)
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.fitness_center,
                    iconColor: AppColors.primary,
                    label: 'Total Volume',
                    value:
                        '${(12150 + FitPulseState.instance.totalVolumeLiftedKg).toStringAsFixed(0)} kg',
                    trend:
                        '+${((FitPulseState.instance.totalVolumeLiftedKg / 100) + 8.4).toStringAsFixed(1)}% vs last wk',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.timer_outlined,
                    iconColor: AppColors.accent,
                    label: 'Active Time',
                    value:
                        '${(14.2 + (FitPulseState.instance.workoutDurationSeconds / 3600)).toStringAsFixed(1)} Hours',
                    trend:
                        '${4 + (FitPulseState.instance.completedSetsCount > 0 ? 1 : 0)} workouts logged',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.local_fire_department_outlined,
                    iconColor: AppColors.energyOrange,
                    label: 'Calories Burned',
                    value:
                        '${(7420 + (FitPulseState.instance.totalVolumeLiftedKg * 0.15).round())} kcal',
                    trend: 'Dynamic metabolic burn',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.emoji_events_outlined,
                    iconColor: Colors.amber.shade700,
                    label: 'Consistency',
                    value: '${FitPulseState.instance.habitConsistencyScore}% Score',
                    trend: FitPulseState.instance.habitConsistencyScore >= 75
                        ? 'Target achieved 🎯'
                        : 'Keep logging habits 💪',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Feature 4: Flagship 1RM Multi-Formula Strength Calculator Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calculate_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1-Rep Max (1RM) Estimator',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Multi-Formula Strength Calculator',
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Calculate your maximum theoretical lift using the Epley, Brzycki, and Lombardi scientific formulas with customized training intensity zones.',
                    style: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showOneRepMaxCalculator,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.fitness_center, size: 16),
                      label: const Text(
                        'OPEN 1RM CALCULATOR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Records (PR) Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personal Records (PRs)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showOneRepMaxCalculator,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add PR'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dynamically render PRs from FitPulseState
            ...FitPulseState.instance.prs.map(
              (pr) => _buildPrCard(
                pr.exercise,
                '${pr.weightKg.toStringAsFixed(1)} kg × ${pr.reps}',
                pr.note.isNotEmpty ? pr.note : 'Recorded ${pr.achievedDate}',
                est1RM: 'Est 1RM: ${pr.estimatedOneRepMaxKg.toStringAsFixed(1)} kg',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Feature 4: Interactive 1-Rep Max Multi-Formula Calculator Modal
  void _showOneRepMaxCalculator() {
    final weightController = TextEditingController(text: '100');
    final repsController = TextEditingController(text: '5');
    String selectedExercise = 'Barbell Bench Press';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          final double weight = double.tryParse(weightController.text) ?? 100.0;
          final int reps = int.tryParse(repsController.text) ?? 5;

          // Multi-formula calculations
          final double epley = weight * (1 + reps / 30.0);
          final double brzycki = reps < 37
              ? weight * (36.0 / (37.0 - reps))
              : weight * 1.5;
          final double lombardi = weight * (reps > 0 ? (1 + 0.10 * (reps - 1)) : 1.0);
          final double avgOneRepMax = (epley + brzycki + lombardi) / 3.0;

          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.calculate,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '1RM Multi-Formula Tool',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const Text(
                      'Scientific estimation based on Epley, Brzycki, & Lombardi equations',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const Divider(height: 24),

                    // Exercise Selector
                    const Text(
                      'Exercise Target',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedExercise,
                          isExpanded: true,
                          items: [
                            'Barbell Bench Press',
                            'Barbell Back Squat',
                            'Conventional Deadlift',
                            'Overhead Press (OHP)',
                            'Barbell Bent-Over Row',
                            'Weighted Pull-Up',
                          ]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedExercise = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Form Fields (Weight & Reps)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lifted Weight (kg)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 100',
                                  suffixText: 'kg',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Enter weight';
                                  }
                                  final num = double.tryParse(val);
                                  if (num == null || num <= 0 || num > 600) {
                                    return '1 - 600 kg';
                                  }
                                  return null;
                                },
                                onChanged: (val) => setModalState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reps Completed',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: repsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'e.g. 5',
                                  suffixText: 'reps',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Enter reps';
                                  }
                                  final num = int.tryParse(val);
                                  if (num == null || num <= 0 || num > 30) {
                                    return '1 - 30 reps';
                                  }
                                  return null;
                                },
                                onChanged: (val) => setModalState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Average Estimated 1RM Hero Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.15),
                            AppColors.primary.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'ESTIMATED 1-REP MAX (AVERAGE)',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${avgOneRepMax.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Formula comparison breakdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildFormulaTag(
                                'Epley',
                                '${epley.toStringAsFixed(1)} kg',
                              ),
                              _buildFormulaTag(
                                'Brzycki',
                                '${brzycki.toStringAsFixed(1)} kg',
                              ),
                              _buildFormulaTag(
                                'Lombardi',
                                '${lombardi.toStringAsFixed(1)} kg',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Training Intensity Percentages
                    const Text(
                      'Training Intensity Zones',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildZoneCard(
                          '95%',
                          '${(avgOneRepMax * 0.95).toStringAsFixed(1)} kg',
                          'Power (1-2 reps)',
                        ),
                        const SizedBox(width: 8),
                        _buildZoneCard(
                          '85%',
                          '${(avgOneRepMax * 0.85).toStringAsFixed(1)} kg',
                          'Strength (4-6 reps)',
                        ),
                        const SizedBox(width: 8),
                        _buildZoneCard(
                          '75%',
                          '${(avgOneRepMax * 0.75).toStringAsFixed(1)} kg',
                          'Hypertrophy (8-10)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save as Personal Record CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            FitPulseState.instance.addPersonalRecord(
                              selectedExercise,
                              weight,
                              reps,
                            );
                            Navigator.pop(modalContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🥇 Personal Record for $selectedExercise updated (${avgOneRepMax.toStringAsFixed(1)} kg 1RM)!',
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.star, color: Colors.amber),
                        label: const Text(
                          'SAVE AS PERSONAL RECORD',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormulaTag(String name, String value) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildZoneCard(String pct, String weight, String target) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardSubtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              pct,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              weight,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              target,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrCard(
    String exercise,
    String record,
    String note, {
    String? est1RM,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  exercise,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  note,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (est1RM != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    est1RM,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
