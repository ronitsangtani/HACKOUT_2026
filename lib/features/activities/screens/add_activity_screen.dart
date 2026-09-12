import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';
import '../../../core/services/ecoloop_api_service.dart';
import '../../../models/firestore_models.dart';

/// Screen allowing consumers to log daily activities across Transport, Energy, Shopping, and Waste.
/// Upon logging, executes carbon calculation and displays lower-carbon circular alternatives.
class AddActivityScreen extends ConsumerStatefulWidget {
  const AddActivityScreen({super.key});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSubmitting = false;

  // Transport Form Controllers & State
  final _transportFormKey = GlobalKey<FormState>();
  String _transportVehicle = 'Car';
  String _transportFuel = 'Petrol';
  final _transportDistanceController = TextEditingController();

  // Energy Form Controllers & State
  final _energyFormKey = GlobalKey<FormState>();
  final _electricityController = TextEditingController();
  final _lpgController = TextEditingController();

  // Shopping Form Controllers & State
  final _shoppingFormKey = GlobalKey<FormState>();
  String _shoppingCategory = 'Groceries & Food';
  final _shoppingAmountController = TextEditingController();
  final _shoppingQuantityController = TextEditingController();

  // Waste Form Controllers & State
  final _wasteFormKey = GlobalKey<FormState>();
  String _wasteType = 'Plastic Packaging';
  final _wasteQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transportDistanceController.dispose();
    _electricityController.dispose();
    _lpgController.dispose();
    _shoppingAmountController.dispose();
    _shoppingQuantityController.dispose();
    _wasteQuantityController.dispose();
    super.dispose();
  }

  Future<void> _submitActivity({
    required String category,
    required String activityType,
    required double quantity,
    required String unit,
  }) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    try {
      final apiService = ref.read(apiServiceProvider);
      final analysis = await apiService.logActivity(
        category: category,
        activityType: activityType,
        quantity: quantity,
        unit: unit,
      );

      // Invalidate providers so dashboard, history and leaderboard refresh with live data
      ref.invalidate(userActivitiesProvider);
      ref.invalidate(leaderboardProvider);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      _showAlternativesModal(analysis);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log activity: '),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAlternativesModal(ActivityAnalysisResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final topAlt = result.alternatives.isNotEmpty ? result.alternatives.first : null;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Activity & Circular Analysis',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Footprint summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your activity generated approximately  kg CO₂',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Activity:  ( )',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Methodology: ',
                        style: const TextStyle(fontSize: 11, color: Colors.black45, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Best Circular Alternative
                if (topAlt != null) ...[
                  const Text(
                    'Recommended Circular Alternative',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Better alternative:\n',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryGreen),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '-%',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Estimated emissions: approximately  kg CO₂',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Potential reduction:\n kg CO₂',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          topAlt.explanation,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Outstanding! This was already a zero or minimal carbon activity. Keep up the circular habit!',
                            style: TextStyle(fontSize: 13, color: AppTheme.darkText, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close sheet
                    Navigator.pop(context); // Close AddActivityScreen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done • View in Activity History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Activity'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: false,
          tabs: const [
            Tab(icon: Icon(Icons.directions_car_outlined), text: 'Transport'),
            Tab(icon: Icon(Icons.bolt_outlined), text: 'Energy'),
            Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Shopping'),
            Tab(icon: Icon(Icons.delete_outline), text: 'Waste'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransportTab(),
          _buildEnergyTab(),
          _buildShoppingTab(),
          _buildWasteTab(),
        ],
      ),
    );
  }

  // 1. Transport Form
  Widget _buildTransportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _transportFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Transport Activity', 'Record your travel and commute emissions.'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _transportVehicle,
              decoration: _inputDecoration('Vehicle Type', Icons.commute),
              items: ['Car', 'Motorcycle / Scooter', 'Bus', 'Train / Metro', 'Auto Rickshaw', 'Bicycle / Walking']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (val) => setState(() => _transportVehicle = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _transportDistanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('Distance Traveled (km)', Icons.straighten, hint: 'e.g. 15.5'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter distance';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Please enter a valid positive distance';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _transportFuel,
              decoration: _inputDecoration('Fuel Type', Icons.local_gas_station_outlined),
              items: ['Petrol', 'Diesel', 'CNG', 'Electric (EV)', 'Human Powered']
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) => setState(() => _transportFuel = val!),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_transportFormKey.currentState!.validate()) {
                        final dist = double.parse(_transportDistanceController.text.trim());
                        _submitActivity(
                          category: 'transport',
                          activityType: ' ()',
                          quantity: dist,
                          unit: 'km',
                        );
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Log Transport Activity'),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Energy Form
  Widget _buildEnergyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _energyFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Household Energy', 'Track electricity meter units and cooking gas usage.'),
            const SizedBox(height: 20),
            TextFormField(
              controller: _electricityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('Electricity Usage (kWh / Units)', Icons.electric_meter_outlined, hint: 'e.g. 12.0'),
              validator: (v) {
                if ((v == null || v.trim().isEmpty) && _lpgController.text.trim().isEmpty) {
                  return 'Enter electricity or LPG consumption';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lpgController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('LPG Usage (kg or % Cylinder)', Icons.propane_tank_outlined, hint: 'e.g. 1.5'),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_energyFormKey.currentState!.validate()) {
                        final elec = double.tryParse(_electricityController.text.trim());
                        if (elec != null && elec > 0) {
                          _submitActivity(
                            category: 'energy',
                            activityType: 'Grid Electricity',
                            quantity: elec,
                            unit: 'kWh',
                          );
                        } else {
                          final lpg = double.tryParse(_lpgController.text.trim()) ?? 1.0;
                          _submitActivity(
                            category: 'energy',
                            activityType: 'LPG Gas',
                            quantity: lpg,
                            unit: 'kg',
                          );
                        }
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Log Energy Activity'),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Shopping Form
  Widget _buildShoppingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _shoppingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Shopping & Goods', 'Consumer items and embedded manufacturing footprints.'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _shoppingCategory,
              decoration: _inputDecoration('Shopping Category', Icons.category_outlined),
              items: ['Groceries & Food', 'Clothing & Fashion', 'Electronics & Gadgets', 'Home & Furniture', 'Personal Care']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _shoppingCategory = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _shoppingAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('Total Spent (₹)', Icons.currency_rupee, hint: 'e.g. 1200'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter amount';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Please enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _shoppingQuantityController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Quantity of Items (Optional)', Icons.tag, hint: 'e.g. 3'),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_shoppingFormKey.currentState!.validate()) {
                        final amt = double.parse(_shoppingAmountController.text.trim());
                        _submitActivity(
                          category: 'shopping',
                          activityType: _shoppingCategory,
                          quantity: amt,
                          unit: 'INR',
                        );
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Log Shopping Activity'),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Waste Form
  Widget _buildWasteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _wasteFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Waste Disposal', 'Log segregated waste and circular recyclables.'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _wasteType,
              decoration: _inputDecoration('Waste Type', Icons.delete_sweep_outlined),
              items: ['Plastic Packaging', 'Organic / Food Waste', 'Paper & Cardboard', 'Electronic Waste (E-waste)', 'Glass & Bottles', 'Metals']
                  .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                  .toList(),
              onChanged: (val) => setState(() => _wasteType = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _wasteQuantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('Quantity (kg)', Icons.scale_outlined, hint: 'e.g. 2.5'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter quantity in kg';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Please enter a valid positive quantity';
                return null;
              },
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_wasteFormKey.currentState!.validate()) {
                        final qty = double.parse(_wasteQuantityController.text.trim());
                        _submitActivity(
                          category: 'waste',
                          activityType: _wasteType,
                          quantity: qty,
                          unit: 'kg',
                        );
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Log Waste Activity'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  static InputDecoration _inputDecoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
      ),
    );
  }
}
