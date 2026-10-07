// ============================================================================
// FitPulse Mobile App — Food Serving Detail & Macro Scaler Modal
// Week 4: API Integration and Asynchronous Data Handling
// Provides interactive serving customization and reactive state synchronization
// ============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/food_item_model.dart';
import '../../core/state/app_state.dart';

class FoodDetailModal extends StatefulWidget {
  final FoodItem food;

  const FoodDetailModal({super.key, required this.food});

  static Future<bool?> show(BuildContext context, FoodItem food) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FoodDetailModal(food: food),
    );
  }

  @override
  State<FoodDetailModal> createState() => _FoodDetailModalState();
}

class _FoodDetailModalState extends State<FoodDetailModal> {
  late double _selectedGrams;
  late TextEditingController _gramsController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedGrams = widget.food.defaultServingGrams;
    _gramsController = TextEditingController(text: _selectedGrams.toInt().toString());
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _updateServing(double grams) {
    setState(() {
      _selectedGrams = grams.clamp(1.0, 2000.0);
      _gramsController.text = _selectedGrams.toInt().toString();
    });
  }

  void _onConfirmLog() {
    if (_formKey.currentState?.validate() ?? false) {
      final scaledKcal = widget.food.scaledCalories(_selectedGrams);
      final scaledP = widget.food.scaledProtein(_selectedGrams);
      final scaledC = widget.food.scaledCarbs(_selectedGrams);
      final scaledF = widget.food.scaledFat(_selectedGrams);

      // Log into global reactive app state
      FitPulseState.instance.logMeal(
        calories: scaledKcal,
        protein: scaledP,
        carbs: scaledC,
        fats: scaledF,
      );

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Logged ${_selectedGrams.toInt()}g of ${widget.food.name} (+${scaledKcal.toInt()} kcal)!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Color _getNutriScoreColor(String score) {
    switch (score) {
      case 'a':
        return const Color(0xFF059669);
      case 'b':
        return const Color(0xFF10B981);
      case 'c':
        return const Color(0xFFF59E0B);
      case 'd':
        return const Color(0xFFEA580C);
      case 'e':
        return const Color(0xFFEF4444);
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final kcal = widget.food.scaledCalories(_selectedGrams);
    final protein = widget.food.scaledProtein(_selectedGrams);
    final carbs = widget.food.scaledCarbs(_selectedGrams);
    final fat = widget.food.scaledFat(_selectedGrams);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag bar
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

              // Title and Nutri-Score badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.food.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.food.brand,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.food.nutriScore != 'unknown')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getNutriScoreColor(widget.food.nutriScore).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getNutriScoreColor(widget.food.nutriScore)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Nutri-Score ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getNutriScoreColor(widget.food.nutriScore),
                            ),
                          ),
                          Text(
                            widget.food.nutriScore.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: _getNutriScoreColor(widget.food.nutriScore),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Macro Overview Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Energy Value',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        Text(
                          '${kcal.toStringAsFixed(0)} kcal',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroPill('Protein', '${protein.toStringAsFixed(1)}g', AppColors.primary),
                        _buildMacroPill('Carbs', '${carbs.toStringAsFixed(1)}g', const Color(0xFFF59E0B)),
                        _buildMacroPill('Fat', '${fat.toStringAsFixed(1)}g', const Color(0xFFEF4444)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Serving Size Controls
              const Text(
                'Customize Serving Size',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              // Quick Serving Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [50.0, 100.0, 150.0, 200.0, 250.0].map((grams) {
                    final isSelected = (_selectedGrams - grams).abs() < 0.1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${grams.toInt()}g'),
                        selected: isSelected,
                        onSelected: (_) => _updateServing(grams),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Grams Input Field
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gramsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Serving Amount (Grams)',
                        suffixText: 'grams',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setState(() => _selectedGrams = parsed);
                        }
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter grams';
                        final num = double.tryParse(val);
                        if (num == null || num <= 0 || num > 2000) return 'Enter 1 - 2000g';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _onConfirmLog,
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                  label: Text(
                    'LOG TO DAILY INTAKE (+${kcal.toStringAsFixed(0)} KCAL)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroPill(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

