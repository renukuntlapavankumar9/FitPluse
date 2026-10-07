// ============================================================================
// FitPulse Mobile App — Food & Nutrition Public REST API Search Screen
// Week 4: API Integration and Asynchronous Data Handling
// Demonstrates: Asynchronous HTTP fetch, debounced search, loading states,
// error handling, offline fallback, and reactive state updates.
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/food_item_model.dart';
import '../../core/services/api_exception.dart';
import '../../core/services/food_api_service.dart';
import 'food_detail_modal.dart';

class FoodSearchScreen extends StatefulWidget {
  final FoodApiService? apiService;

  const FoodSearchScreen({super.key, this.apiService});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  late final FoodApiService _apiService;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false;
  List<FoodItem> _foodItems = [];
  String _activeCategory = 'All';

  final List<String> _quickCategories = [
    'All',
    'Oats',
    'Chicken',
    'Eggs',
    'Greek Yogurt',
    'Whey Protein',
    'Banana',
    'Almonds',
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? FoodApiService();
    // Pre-populate with initial query
    _performSearch('oats');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().isNotEmpty) {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isOfflineMode = false;
    });

    try {
      final results = await _apiService.searchFood(query);
      if (mounted) {
        setState(() {
          _foodItems = results;
          _isLoading = false;
          if (results.isEmpty) {
            _errorMessage = 'No products found matching "$query". Try broader search terms.';
          }
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network connection failed: $e';
        });
      }
    }
  }

  void _loadOfflineFallback() {
    setState(() {
      _isLoading = false;
      _errorMessage = null;
      _isOfflineMode = true;
      _foodItems = _apiService.getOfflineFallbackFoods();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Switched to FitPulse Offline Nutrition Cache'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _selectCategoryChip(String category) {
    setState(() {
      _activeCategory = category;
      _searchController.text = category == 'All' ? 'oats' : category;
    });
    _performSearch(category == 'All' ? 'oats' : category);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Database API',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Powered by Open Food Facts Public REST API',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isOfflineMode ? Icons.cloud_off : Icons.cloud_done,
              color: _isOfflineMode ? Colors.orange : AppColors.primary,
            ),
            tooltip: _isOfflineMode ? 'Offline Cache Active' : 'Live Cloud API',
            onPressed: () {
              if (_isOfflineMode) {
                _performSearch(_searchController.text.isNotEmpty ? _searchController.text : 'oats');
              } else {
                _loadOfflineFallback();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _performSearch,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search food (e.g. Oats, Greek Yogurt)...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('oats');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Quick Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickCategories.map((cat) {
                      final isSelected = _activeCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => _selectCategoryChip(cat),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Offline Status Banner
          if (_isOfflineMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Offline Cache Mode: Displaying verified fitness nutrition dataset.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _performSearch(_searchController.text.isNotEmpty ? _searchController.text : 'oats'),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text('Try Online', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // Dynamic Body (Loading / Error / Empty / Results)
          Expanded(
            child: _buildBodyContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Fetching Live Data from Open Food Facts API...',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Asynchronous GET: cgi/search.pl?search_terms=${_searchController.text}',
              style: const TextStyle(fontSize: 11, color: AppColors.border, fontFamily: 'monospace'),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_off, size: 48, color: Colors.red.shade400),
              ),
              const SizedBox(height: 16),
              const Text(
                'Data Retrieval Issue Encountered',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _performSearch(_searchController.text.isNotEmpty ? _searchController.text : 'oats'),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loadOfflineFallback,
                    icon: const Icon(Icons.storage, size: 18),
                    label: const Text('Use Cached Data'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_foodItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No Food Items Found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try searching with general terms like "oats", "chicken", or "milk"',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _foodItems.length,
      itemBuilder: (context, index) {
        final item = _foodItems[index];
        return _buildFoodCard(item);
      },
    );
  }

  Widget _buildFoodCard(FoodItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () => FoodDetailModal.show(context, item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title, Brand, and Nutri-Score
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.brand,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.nutriScore != 'unknown')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getNutriScoreColor(item.nutriScore).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _getNutriScoreColor(item.nutriScore)),
                      ),
                      child: Text(
                        'GRADE ${item.nutriScore.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: _getNutriScoreColor(item.nutriScore),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Macro Badges Row (per 100g)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInlineMacro('Calories', '${item.caloriesPer100g.toStringAsFixed(0)} kcal', AppColors.primary),
                    _buildInlineMacro('Protein', '${item.proteinPer100g.toStringAsFixed(1)}g', AppColors.primary),
                    _buildInlineMacro('Carbs', '${item.carbsPer100g.toStringAsFixed(1)}g', const Color(0xFFF59E0B)),
                    _buildInlineMacro('Fat', '${item.fatPer100g.toStringAsFixed(1)}g', const Color(0xFFEF4444)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Bottom action hint
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Values normalized per 100g',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  Row(
                    children: [
                      Text(
                        'Scale & Log',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineMacro(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

