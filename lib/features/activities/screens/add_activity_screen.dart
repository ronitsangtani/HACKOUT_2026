import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';
import '../../../core/services/ecoloop_api_service.dart';
import '../../../core/widgets/eco_progress_bar.dart';
import '../../../core/widgets/primary_game_button.dart';
import '../../../models/firestore_models.dart';
import '../../auth/providers/auth_providers.dart';

/// Duolingo-styled interactive Lesson-based Add Activity Flow.
/// Features 1-question-at-a-time navigation, top progress bar, tactile option selection,
/// and celebration feedback screen with real carbon calculation and alternatives.
class AddActivityScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const AddActivityScreen({super.key, this.initialCategory});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  int _currentStep = 0; // 0: Category, 1: Activity Type, 2: Quantity, 3: Celebration Result
  bool _isSubmitting = false;

  // Selected state
  String? _selectedCategory;
  Map<String, dynamic>? _selectedActivity;
  double _quantity = 15.0;

  // Result state from backend calculation
  ActivityAnalysisResult? _analysisResult;

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Transport', 'emoji': '🚗', 'subtitle': 'Commute & Travel', 'color': AppTheme.duoGreen},
    {'name': 'Energy', 'emoji': '⚡', 'subtitle': 'Electricity & Gas', 'color': AppTheme.duoYellow},
    {'name': 'Food', 'emoji': '🍽️', 'subtitle': 'Meals & Diet', 'color': AppTheme.duoOrange},
    {'name': 'Waste', 'emoji': '♻️', 'subtitle': 'Disposal & Recycling', 'color': AppTheme.duoBlue},
    {'name': 'Shopping', 'emoji': '🛍️', 'subtitle': 'Goods & Devices', 'color': Color(0xFFCE82FF)},
    {'name': 'Water', 'emoji': '💧', 'subtitle': 'Usage & Conservation', 'color': Color(0xFF1CB0F6)},
  ];

  final Map<String, List<Map<String, dynamic>>> _activitiesMap = const {
    'Transport': [
      {'name': 'Solo Petrol Car', 'emoji': '🚗', 'unit': 'km', 'defaultQty': 15.0, 'co2Factor': 0.192, 'presets': [5.0, 15.0, 30.0, 60.0]},
      {'name': 'City Bus', 'emoji': '🚌', 'unit': 'km', 'defaultQty': 10.0, 'co2Factor': 0.089, 'presets': [5.0, 10.0, 20.0, 40.0]},
      {'name': 'Metro / Train', 'emoji': '🚆', 'unit': 'km', 'defaultQty': 12.0, 'co2Factor': 0.035, 'presets': [5.0, 12.0, 25.0, 50.0]},
      {'name': 'Bicycle / Walking', 'emoji': '🚲', 'unit': 'km', 'defaultQty': 5.0, 'co2Factor': 0.0, 'presets': [2.0, 5.0, 10.0, 20.0]},
      {'name': 'Electric Vehicle (EV)', 'emoji': '⚡', 'unit': 'km', 'defaultQty': 20.0, 'co2Factor': 0.053, 'presets': [10.0, 20.0, 40.0, 80.0]},
    ],
    'Energy': [
      {'name': 'Grid Electricity', 'emoji': '💡', 'unit': 'kWh', 'defaultQty': 10.0, 'co2Factor': 0.71, 'presets': [5.0, 10.0, 25.0, 50.0]},
      {'name': 'LPG Cylinder', 'emoji': '🔥', 'unit': 'kg', 'defaultQty': 2.0, 'co2Factor': 1.51, 'presets': [1.0, 2.0, 5.0, 14.0]},
      {'name': 'Rooftop Solar Power', 'emoji': '☀️', 'unit': 'kWh', 'defaultQty': 15.0, 'co2Factor': 0.02, 'presets': [5.0, 15.0, 30.0, 50.0]},
    ],
    'Food': [
      {'name': 'Meat-Heavy Meal', 'emoji': '🥩', 'unit': 'meals', 'defaultQty': 1.0, 'co2Factor': 3.2, 'presets': [1.0, 2.0, 3.0, 4.0]},
      {'name': 'Plant-Based Meal', 'emoji': '🥗', 'unit': 'meals', 'defaultQty': 1.0, 'co2Factor': 0.6, 'presets': [1.0, 2.0, 3.0, 4.0]},
      {'name': 'Dairy & Coffee', 'emoji': '☕', 'unit': 'servings', 'defaultQty': 2.0, 'co2Factor': 0.8, 'presets': [1.0, 2.0, 3.0, 5.0]},
    ],
    'Waste': [
      {'name': 'Landfill Trash', 'emoji': '🗑️', 'unit': 'kg', 'defaultQty': 2.0, 'co2Factor': 1.25, 'presets': [1.0, 2.0, 5.0, 10.0]},
      {'name': 'Polymer Recycling Hub', 'emoji': '♻️', 'unit': 'kg', 'defaultQty': 1.5, 'co2Factor': 0.15, 'presets': [0.5, 1.5, 3.0, 5.0]},
      {'name': 'Organic Compost', 'emoji': '🍂', 'unit': 'kg', 'defaultQty': 2.0, 'co2Factor': 0.05, 'presets': [1.0, 2.0, 5.0, 8.0]},
    ],
    'Shopping': [
      {'name': 'Fast Fashion Clothing', 'emoji': '👕', 'unit': 'items', 'defaultQty': 1.0, 'co2Factor': 8.5, 'presets': [1.0, 2.0, 3.0, 5.0]},
      {'name': 'Consumer Electronics', 'emoji': '📱', 'unit': 'items', 'defaultQty': 1.0, 'co2Factor': 45.0, 'presets': [1.0, 2.0]},
      {'name': 'Groceries & Essentials', 'emoji': '🍏', 'unit': 'kg', 'defaultQty': 5.0, 'co2Factor': 0.45, 'presets': [2.0, 5.0, 10.0, 20.0]},
    ],
    'Water': [
      {'name': 'Hot Shower', 'emoji': '🚿', 'unit': 'mins', 'defaultQty': 8.0, 'co2Factor': 0.18, 'presets': [5.0, 8.0, 12.0, 20.0]},
      {'name': 'Tap Water Usage', 'emoji': '💧', 'unit': 'litres', 'defaultQty': 50.0, 'co2Factor': 0.003, 'presets': [20.0, 50.0, 100.0, 200.0]},
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
      _currentStep = 1;
    }
  }

  int _calculatePointsDelta({
    required String category,
    required String activityName,
    required double quantity,
    required double co2Kg,
  }) {
    final cat = category.toLowerCase().trim();
    final act = activityName.toLowerCase().trim();

    // 1. Transport
    if (cat.contains('transport')) {
      if (act.contains('bicycle') || act.contains('walking') || act.contains('cycle')) {
        return 35 + (quantity > 5.0 ? 5 : 0);
      } else if (act.contains('metro') || act.contains('train')) {
        return 25;
      } else if (act.contains('ev') || act.contains('electric')) {
        return 15;
      } else if (act.contains('bus')) {
        return 10;
      } else if (act.contains('car') || act.contains('petrol') || act.contains('diesel')) {
        final penalty = 15 + (quantity / 2.0).floor();
        return -penalty.clamp(15, 45);
      } else {
        return co2Kg > 2.0 ? -10 : 5;
      }
    }

    // 2. Energy
    else if (cat.contains('energy')) {
      if (act.contains('solar') || act.contains('renewable')) {
        return 30;
      } else if (act.contains('electricity')) {
        if (quantity <= 8.0) {
          return 10;
        } else if (quantity <= 15.0) {
          return 0;
        } else if (quantity <= 30.0) {
          return -15;
        } else {
          return -30;
        }
      } else if (act.contains('lpg') || act.contains('gas')) {
        return quantity <= 1.0 ? -10 : -25;
      } else {
        return co2Kg > 5.0 ? -15 : 5;
      }
    }

    // 3. Food / Diet
    else if (cat.contains('food') || cat.contains('diet')) {
      if (act.contains('plant') || act.contains('vegan') || act.contains('salad')) {
        return (25 * quantity.clamp(1.0, 3.0)).round();
      } else if (act.contains('dairy') || act.contains('coffee')) {
        return quantity <= 2.0 ? 5 : -10;
      } else if (act.contains('meat') || act.contains('beef') || act.contains('chicken')) {
        return -(20 * quantity.clamp(1.0, 3.0)).round();
      } else {
        return co2Kg > 2.0 ? -10 : 10;
      }
    }

    // 4. Waste
    else if (cat.contains('waste')) {
      if (act.contains('compost') || act.contains('organic')) {
        return 30;
      } else if (act.contains('recycle') || act.contains('polymer')) {
        return 25;
      } else if (act.contains('trash') || act.contains('landfill')) {
        return -20;
      } else {
        return co2Kg < 0.5 ? 15 : -15;
      }
    }

    // 5. Shopping / Goods
    else if (cat.contains('shop') || cat.contains('goods')) {
      if (act.contains('fashion') || act.contains('cloth')) {
        return -(25 * quantity.clamp(1.0, 3.0)).round();
      } else if (act.contains('electronic') || act.contains('device') || act.contains('phone')) {
        return -35;
      } else if (act.contains('grocer') || act.contains('essential')) {
        if (quantity <= 5.0) return 10;
        if (quantity <= 10.0) return 0;
        return -10;
      } else {
        return co2Kg > 3.0 ? -20 : 5;
      }
    }

    // 6. Water
    else if (cat.contains('water')) {
      if (act.contains('shower')) {
        if (quantity <= 5.0) return 15;
        if (quantity <= 10.0) return 0;
        return -15;
      } else {
        return quantity <= 50.0 ? 10 : -15;
      }
    }

    // Generic fallback
    if (co2Kg <= 0.5) return 20;
    if (co2Kg <= 2.0) return 5;
    return -(co2Kg * 5).round().clamp(10, 35);
  }

  Future<void> _submitActivity() async {
    final user = ref.read(authStateProvider).value;
    if (_selectedCategory == null || _selectedActivity == null) return;

    setState(() => _isSubmitting = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      final res = await apiService.logActivity(
        category: _selectedCategory!.toLowerCase(),
        activityType: _selectedActivity!['name'] as String,
        quantity: _quantity,
        unit: _selectedActivity!['unit'] as String,
      );

      final int pointsDelta = res.ecoPointsDelta != 0
          ? res.ecoPointsDelta
          : _calculatePointsDelta(
              category: _selectedCategory!,
              activityName: _selectedActivity!['name'] as String,
              quantity: _quantity,
              co2Kg: res.activity.co2Kg,
            );

      // Update Firestore user profile ecoPoints (clamped at 0 minimum)
      if (user != null) {
        try {
          final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
          final snap = await userRef.get();
          if (snap.exists && snap.data() != null) {
            final curr = (snap.data()!['ecoPoints'] as num?)?.toInt() ?? 50;
            final updated = (curr + pointsDelta).clamp(0, 999999);
            await userRef.update({'ecoPoints': updated});
          }
        } catch (_) {}
      }

      setState(() {
        _analysisResult = res.ecoPointsDelta != 0
            ? res
            : ActivityAnalysisResult(
                activity: res.activity,
                formulaUsed: res.formulaUsed,
                ecoPointsDelta: pointsDelta,
                isPositive: pointsDelta > 0,
                alternatives: res.alternatives,
              );
        _currentStep = 3; // Move to Celebration Screen!
      });

      // Refresh providers in background
      ref.invalidate(userActivitiesProvider);
      if (user != null) {
        ref.invalidate(userProfileProvider(user.uid));
      }
    } catch (e) {
      // Graceful fallback for offline / mock calculation
      final factor = (_selectedActivity!['co2Factor'] as num?)?.toDouble() ?? 0.15;
      final calcCo2 = _quantity * factor;
      final pointsDelta = _calculatePointsDelta(
        category: _selectedCategory!,
        activityName: _selectedActivity!['name'] as String,
        quantity: _quantity,
        co2Kg: calcCo2,
      );

      // Update Firestore user profile ecoPoints (clamped at 0 minimum)
      if (user != null) {
        try {
          final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
          final snap = await userRef.get();
          if (snap.exists && snap.data() != null) {
            final curr = (snap.data()!['ecoPoints'] as num?)?.toInt() ?? 50;
            final updated = (curr + pointsDelta).clamp(0, 999999);
            await userRef.update({'ecoPoints': updated});
          }
        } catch (_) {}
      }

      setState(() {
        _analysisResult = ActivityAnalysisResult(
          activity: ActivityRecord(
            activityId: 'act_${DateTime.now().millisecondsSinceEpoch}',
            userId: user?.uid ?? 'guest_user',
            category: _selectedCategory!.toLowerCase(),
            activityType: _selectedActivity!['name'] as String,
            quantity: _quantity,
            unit: _selectedActivity!['unit'] as String,
            co2Kg: calcCo2,
            createdAt: DateTime.now(),
          ),
          formulaUsed: 'IPCC Standard Emission Factors',
          ecoPointsDelta: pointsDelta,
          isPositive: pointsDelta > 0,
          alternatives: [
            AlternativeSuggestion(
              title: _selectedCategory == 'Transport'
                  ? 'Switch to Metro Commute'
                  : 'Clean Energy Shift',
              category: _selectedCategory ?? 'general',
              alternativeType: 'transit',
              estimatedCo2Kg: calcCo2 * 0.25,
              co2ReductionKg: (calcCo2 * 0.75).clamp(0.2, 50.0),
              percentageReduction: 75.0,
              explanation: 'Taking mass transit reduces urban congestion and cuts emissions drastically.',
            ),
          ],
        );
        _currentStep = 3;
      });

      ref.invalidate(userActivitiesProvider);
      if (user != null) {
        ref.invalidate(userProfileProvider(user.uid));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleBack() {
    if (_currentStep > 0 && _currentStep < 3) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double stepProgress = ((_currentStep + 1) / 4).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_currentStep == 0 || _currentStep == 3 ? Icons.close_rounded : Icons.arrow_back_rounded),
          color: AppTheme.duoText,
          iconSize: 28,
          onPressed: _handleBack,
        ),
        title: EcoProgressBar(
          progress: stepProgress,
          height: 14,
          fillColor: AppTheme.duoGreen,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Row(
              children: [
                Text('🌱', style: TextStyle(fontSize: 18)),
                SizedBox(width: 4),
                Text('LESSON', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.duoGreenDark)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildCurrentStepView(),
              ),
            ),
            if (_currentStep < 3) _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStepCategorySelection();
      case 1:
        return _buildStepActivitySelection();
      case 2:
        return _buildStepQuantityInput();
      case 3:
      default:
        return _buildStepCelebrationResult();
    }
  }

  // STEP 1: Select Category
  Widget _buildStepCategorySelection() {
    return SingleChildScrollView(
      key: const ValueKey('step_category'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What did you do today?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.duoText),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pick a sustainability sector to track your daily carbon loop',
            style: TextStyle(fontSize: 14, color: AppTheme.duoSubtext, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat['name'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat['name'] as String;
                    _selectedActivity = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.duoGreenLight.withValues(alpha: 0.5) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.duoGreen : AppTheme.duoGray,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? AppTheme.duoGreenDark : AppTheme.duoGray,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat['emoji'] as String, style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isSelected ? AppTheme.duoGreenDark : AppTheme.duoText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cat['subtitle'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, color: AppTheme.duoSubtext, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // STEP 2: Select Specific Activity
  Widget _buildStepActivitySelection() {
    final list = _activitiesMap[_selectedCategory] ?? _activitiesMap['Transport']!;

    return SingleChildScrollView(
      key: const ValueKey('step_activity'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which ${_selectedCategory?.toLowerCase()} action?',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.duoText),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select the exact vehicle, appliance or material you used',
            style: TextStyle(fontSize: 14, color: AppTheme.duoSubtext, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ...list.map((act) {
            final isSelected = _selectedActivity?['name'] == act['name'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedActivity = act;
                    _quantity = (act['defaultQty'] as num).toDouble();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.duoGreenLight.withValues(alpha: 0.5) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppTheme.duoGreen : AppTheme.duoGray,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? AppTheme.duoGreenDark : AppTheme.duoGray,
                        offset: const Offset(0, 3.5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.duoGrayLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(act['emoji'] as String, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          act['name'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? AppTheme.duoGreenDark : AppTheme.duoText,
                          ),
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppTheme.duoGreen : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppTheme.duoGreen : AppTheme.duoGrayDark,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // STEP 3: Enter Quantity
  Widget _buildStepQuantityInput() {
    final unit = _selectedActivity?['unit'] as String? ?? 'units';
    final presets = (_selectedActivity?['presets'] as List<dynamic>?)?.cast<double>() ?? [5.0, 10.0, 25.0, 50.0];

    return SingleChildScrollView(
      key: const ValueKey('step_quantity'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How much did you record?',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.duoText),
          ),
          const SizedBox(height: 6),
          Text(
            'Quantity in $unit for ${_selectedActivity?['name']}',
            style: const TextStyle(fontSize: 14, color: AppTheme.duoSubtext, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 36),

          // Big tactile counter display
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.duoGrayLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.duoGray, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    _quantity % 1 == 0 ? _quantity.toInt().toString() : _quantity.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.duoGreenDark,
                    ),
                  ),
                  Text(
                    unit.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.duoSubtext,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stepper +/- Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepperButton(
                icon: Icons.remove_rounded,
                onTap: () {
                  if (_quantity > 1) {
                    setState(() => _quantity = (_quantity - 1).clamp(0.5, 500.0));
                  }
                },
              ),
              const SizedBox(width: 24),
              _buildStepperButton(
                icon: Icons.add_rounded,
                onTap: () {
                  setState(() => _quantity = (_quantity + 1).clamp(0.5, 500.0));
                },
              ),
            ],
          ),

          const SizedBox(height: 28),
          const Text(
            'QUICK PRESETS',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.duoSubtext, letterSpacing: 0.8),
          ),
          const SizedBox(height: 10),

          // Preset Chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: presets.map((p) {
              final isMatch = _quantity == p;
              return GestureDetector(
                onTap: () => setState(() => _quantity = p),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMatch ? AppTheme.duoGreen : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMatch ? AppTheme.duoGreenDark : AppTheme.duoGray,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${p.toInt()} $unit',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: isMatch ? Colors.white : AppTheme.duoText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.duoGray, width: 2),
          boxShadow: const [
            BoxShadow(color: AppTheme.duoGray, offset: Offset(0, 3)),
          ],
        ),
        child: Icon(icon, color: AppTheme.duoText, size: 28),
      ),
    );
  }

  // STEP 4: Duolingo-style Celebration & Better Choice Screen
  Widget _buildStepCelebrationResult() {
    final co2 = _analysisResult?.activity.co2Kg ?? (_quantity * 0.192);
    final alternatives = _analysisResult?.alternatives ?? [];
    final pointsDelta = _analysisResult?.ecoPointsDelta ?? _calculatePointsDelta(
      category: _selectedCategory ?? '',
      activityName: _selectedActivity?['name'] as String? ?? '',
      quantity: _quantity,
      co2Kg: co2,
    );

    final bool isReward = pointsDelta > 0;
    final bool isPenalty = pointsDelta < 0;

    final Color badgeBg = isReward
        ? AppTheme.duoGreenLight.withValues(alpha: 0.5)
        : isPenalty
            ? AppTheme.duoOrangeLight.withValues(alpha: 0.5)
            : AppTheme.duoGrayLight;

    final Color badgeBorder = isReward
        ? AppTheme.duoGreen
        : isPenalty
            ? AppTheme.duoOrange
            : AppTheme.duoGray;

    final Color badgeTextColor = isReward
        ? AppTheme.duoGreenDark
        : isPenalty
            ? AppTheme.duoOrangeDark
            : AppTheme.duoSubtext;

    final String pointsText = isReward
        ? '+$pointsDelta 🌱'
        : isPenalty
            ? '$pointsDelta 🔻'
            : '0 🌱';

    final String badgeLabel = isReward
        ? 'EARNED'
        : isPenalty
            ? 'PENALTY'
            : 'NEUTRAL';

    final String badgeSubtext = isReward
        ? 'Eco Points'
        : isPenalty
            ? 'Points Deducted'
            : 'Baseline Met';

    final String heroEmoji = isReward
        ? '🌱'
        : isPenalty
            ? '⚠️'
            : '🌍';

    final String heroTitle = isReward
        ? 'SUSTAINABLE CHOICE!'
        : isPenalty
            ? 'HIGH CARBON FOOTPRINT!'
            : 'ACTIVITY LOGGED!';

    final Color heroColor = isReward
        ? AppTheme.duoGreenDark
        : isPenalty
            ? AppTheme.duoOrangeDark
            : AppTheme.duoText;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Celebration / Warning Globe
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isPenalty ? AppTheme.duoOrangeLight : AppTheme.duoGreenLight,
                shape: BoxShape.circle,
                border: Border.all(color: isPenalty ? AppTheme.duoOrange : AppTheme.duoGreen, width: 4),
              ),
              alignment: Alignment.center,
              child: Text(heroEmoji, style: const TextStyle(fontSize: 54)),
            ),
            const SizedBox(height: 16),
            Text(
              heroTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: heroColor),
            ),
            const SizedBox(height: 6),
            Text(
              'You recorded ${_selectedActivity?['name']}',
              style: const TextStyle(fontSize: 14, color: AppTheme.duoSubtext, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Carbon Impact & Points Cards Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.duoGrayLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.duoGray, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text('FOOTPRINT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.duoSubtext)),
                        const SizedBox(height: 6),
                        Text(
                          '${co2.toStringAsFixed(1)} kg',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppTheme.duoText),
                        ),
                        const Text('CO₂e generated', style: TextStyle(fontSize: 11, color: AppTheme.duoSubtext)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeBorder, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(badgeLabel, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: badgeTextColor)),
                        const SizedBox(height: 6),
                        Text(
                          pointsText,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: badgeTextColor),
                        ),
                        Text(badgeSubtext, style: TextStyle(fontSize: 11, color: badgeTextColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (isPenalty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.duoOrangeLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.duoOrange, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Text('⚠️', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This action generated high carbon emissions exceeding baseline standards. Choose the recommended alternatives below to recover points!',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.duoOrangeDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Better Choice Circular Recommendation Card
            if (alternatives.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.duoBlueLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.duoBlue, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.duoBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '🌱 BETTER CHOICE',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white, letterSpacing: 0.6),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '-${alternatives.first.percentageReduction.toInt()}% CO₂',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.duoGreenDark, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      alternatives.first.title,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.duoText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alternatives.first.explanation,
                      style: const TextStyle(fontSize: 13, color: AppTheme.duoSubtext),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.duoGray, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Saving:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.duoText)),
                          Text(
                            '~${alternatives.first.co2ReductionKg.toStringAsFixed(1)} kg CO₂',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.duoGreenDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            PrimaryGameButton(
              text: 'CONTINUE',
              color: GameButtonColor.green,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // Fixed Bottom Bar with Continue button
  Widget _buildBottomActionBar() {
    final bool canContinue = _currentStep == 0
        ? _selectedCategory != null
        : _currentStep == 1
            ? _selectedActivity != null
            : _quantity > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.duoGray, width: 2)),
      ),
      child: PrimaryGameButton(
        text: _currentStep == 2 ? 'CALCULATE & LOG' : 'CONTINUE',
        color: canContinue ? GameButtonColor.green : GameButtonColor.gray,
        isLoading: _isSubmitting,
        onPressed: canContinue
            ? () {
                if (_currentStep == 0) {
                  setState(() => _currentStep = 1);
                } else if (_currentStep == 1) {
                  setState(() => _currentStep = 2);
                } else if (_currentStep == 2) {
                  _submitActivity();
                }
              }
            : null,
      ),
    );
  }
}
