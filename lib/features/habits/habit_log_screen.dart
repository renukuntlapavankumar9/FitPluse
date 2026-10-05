import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';

/// Habit Log Screen — Interactive Habit Forge with Validation, Filtering & Real-time Streaks
class HabitLogScreen extends StatefulWidget {
  const HabitLogScreen({super.key});

  @override
  State<HabitLogScreen> createState() => _HabitLogScreenState();
}

class _HabitLogScreenState extends State<HabitLogScreen> {
  int _selectedDayIndex = 3; // Defaults to "Today" (Thursday)
  String _filter = 'All';

  final List<Map<String, String>> _weekDays = [
    {'day': 'Mon', 'date': '22'},
    {'day': 'Tue', 'date': '23'},
    {'day': 'Wed', 'date': '24'},
    {'day': 'Thu', 'date': '25'},
    {'day': 'Fri', 'date': '26'},
    {'day': 'Sat', 'date': '27'},
    {'day': 'Sun', 'date': '28'},
  ];

  void _showAddHabitSheet() {
    final titleController = TextEditingController();
    final targetController = TextEditingController(text: 'Daily');
    String selectedCategory = 'Fitness';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
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
                              Icon(Icons.add_task, color: AppColors.accent, size: 24),
                              SizedBox(width: 8),
                              Text('Create New Habit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      const Text(
                        'Set an intentional daily routine with verified target metrics to build consistent habits.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'e.g. 10,000 Daily Steps',
                          labelText: 'Habit Name',
                          prefixIcon: const Icon(Icons.fitness_center),
                          filled: true,
                          fillColor: AppColors.cardSubtle,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter a habit title';
                          if (val.trim().length < 3) return 'Title must be at least 3 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: targetController,
                        decoration: InputDecoration(
                          hintText: 'e.g. 30 mins, 2 Liters, 15 pages',
                          labelText: 'Target Metric / Goal',
                          prefixIcon: const Icon(Icons.flag_outlined),
                          filled: true,
                          fillColor: AppColors.cardSubtle,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Specify a daily target value';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Fitness', 'Hydration', 'Nutrition', 'Mindset', 'Wellness'].map((cat) {
                          final isSelected = selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppColors.primaryLight,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => selectedCategory = cat);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              FitPulseState.instance.createHabit(
                                title: titleController.text.trim(),
                                category: selectedCategory,
                                time: 'Daily Target',
                                targetValue: targetController.text.trim(),
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('New habit created! Streak counter activated 🌟'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: const Text('SAVE & ACTIVATE HABIT', style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final state = FitPulseState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final completedCount = state.habits.where((h) => h.isCompleted).length;
        final totalCount = state.habits.length;
        final completionRate = totalCount > 0 ? (completedCount / totalCount) : 0.0;

        final filteredHabits = state.habits.where((h) {
          if (_filter == 'Pending') return !h.isCompleted;
          if (_filter == 'Completed') return h.isCompleted;
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Habit Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Streak Shield active: Missed habits can be recovered within 24h.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddHabitSheet,
            backgroundColor: AppColors.accent,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Habit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: Column(
            children: [
              // 7-Day Calendar Strip
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                color: AppColors.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_weekDays.length, (index) {
                    final isSelected = _selectedDayIndex == index;
                    final isToday = index == 3;
                    final item = _weekDays[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDayIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 46,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : (isToday ? AppColors.primaryLight : AppColors.cardSubtle),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (isToday ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border),
                            width: isToday ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item['day']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white70 : (isToday ? AppColors.primary : AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['date']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : (isToday ? AppColors.primary : AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // Dynamic Consistency Progress Banner
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Consistency Score', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text('$completedCount of $totalCount finished today', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.energyLight, borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_fire_department, color: AppColors.energyOrange, size: 14),
                                SizedBox(width: 4),
                                Text('12d Streak', style: TextStyle(color: AppColors.energyOrange, fontWeight: FontWeight.bold, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: completionRate,
                          backgroundColor: AppColors.cardSubtle,
                          valueColor: AlwaysStoppedAnimation<Color>(completionRate >= 1.0 ? AppColors.success : AppColors.accent),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: ['All', 'Pending', 'Completed'].map((filterName) {
                    final isSelected = _filter == filterName;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(filterName),
                        selected: isSelected,
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _filter = filterName;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Interactive Habits List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filteredHabits.length,
                  itemBuilder: (context, index) {
                    final habit = filteredHabits[index];
                    final isDone = habit.isCompleted;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFFF9FAFB) : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDone ? AppColors.success.withValues(alpha: 0.35) : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.success.withValues(alpha: 0.12) : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            habit.category == 'Hydration'
                                ? Icons.water_drop_rounded
                                : habit.category == 'Fitness'
                                    ? Icons.directions_run_rounded
                                    : habit.category == 'Mindset'
                                        ? Icons.menu_book_rounded
                                        : Icons.self_improvement_rounded,
                            color: isDone ? AppColors.success : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          habit.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${habit.category} • Target: ${habit.targetValue}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (habit.streak > 0)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department, size: 12, color: AppColors.energyOrange),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${habit.streak}d',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.energyOrange),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        trailing: Checkbox(
                          value: isDone,
                          activeColor: AppColors.accent,
                          onChanged: (val) {
                            state.toggleHabit(habit.id);
                          },
                        ),
                        onTap: () {
                          state.toggleHabit(habit.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
