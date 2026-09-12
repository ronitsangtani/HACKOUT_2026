import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// What-If Simulator Screen allowing consumers to test how lifestyle tweaks
/// project future carbon reduction percentages.
class WhatIfSimulatorScreen extends StatefulWidget {
  const WhatIfSimulatorScreen({super.key});

  @override
  State<WhatIfSimulatorScreen> createState() => _WhatIfSimulatorScreenState();
}

class _WhatIfSimulatorScreenState extends State<WhatIfSimulatorScreen> {
  // Baseline footprint (kg CO2e / month)
  static const double _baselineMonthlyKg = 320.0;

  // Adjustable lifestyle parameters
  double _carKmPerWeek = 80.0; // 0 to 200 km
  double _meatlessDaysPerWeek = 1.0; // 0 to 7 days
  double _acHoursPerDay = 8.0; // 0 to 16 hours
  double _renewableEnergyPercent = 15.0; // 0 to 100%

  // Mock calculation logic
  double get _projectedMonthlyKg {
    // Car reduction: Baseline assumes ~100 km/wk (~18 kg CO2/wk = 72 kg/mo)
    final carSavings = (120 - _carKmPerWeek) * 0.18 * 4.0;

    // Diet reduction: Each plant-based day saves ~2.5 kg CO2/day = ~10 kg/mo
    final dietSavings = _meatlessDaysPerWeek * 2.5 * 4.0;

    // AC reduction: Baseline 10 hrs. Each hour reduced saves ~0.6 kg CO2/day = ~18 kg/mo
    final acSavings = max(0.0, (10 - _acHoursPerDay) * 0.6 * 30.0);

    // Renewable energy: Saves proportional to electricity footprint (~90 kg base)
    final renewableSavings = (_renewableEnergyPercent / 100.0) * 90.0;

    final totalSavings = carSavings + dietSavings + acSavings + renewableSavings;
    return max(85.0, _baselineMonthlyKg - totalSavings);
  }

  double get _reductionKg => max(0.0, _baselineMonthlyKg - _projectedMonthlyKg);
  double get _reductionPercentage => (_reductionKg / _baselineMonthlyKg) * 100.0;

  void _resetDefaults() {
    setState(() {
      _carKmPerWeek = 80.0;
      _meatlessDaysPerWeek = 1.0;
      _acHoursPerDay = 8.0;
      _renewableEnergyPercent = 15.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What-If Simulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to Defaults',
            onPressed: _resetDefaults,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Projected Impact Hero Card
              _buildProjectionHeroCard(),

              const SizedBox(height: 24),

              const Text(
                'Adjust Lifestyle Parameters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
              ),
              const SizedBox(height: 4),
              const Text(
                'Move sliders to simulate circular choices and renewable shifts.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),

              // Parameter 1: Solo Car Commute
              _buildSliderCard(
                title: 'Solo Car Travel',
                valueDisplay: '${_carKmPerWeek.round()} km / week',
                icon: Icons.directions_car_outlined,
                color: Colors.blue.shade700,
                min: 0,
                max: 200,
                divisions: 20,
                value: _carKmPerWeek,
                onChanged: (val) => setState(() => _carKmPerWeek = val),
              ),
              const SizedBox(height: 12),

              // Parameter 2: Meatless Days
              _buildSliderCard(
                title: 'Plant-Based / Meatless Days',
                valueDisplay: '${_meatlessDaysPerWeek.round()} days / week',
                icon: Icons.restaurant_outlined,
                color: Colors.green.shade700,
                min: 0,
                max: 7,
                divisions: 7,
                value: _meatlessDaysPerWeek,
                onChanged: (val) => setState(() => _meatlessDaysPerWeek = val),
              ),
              const SizedBox(height: 12),

              // Parameter 3: AC Usage
              _buildSliderCard(
                title: 'Air Conditioner Usage',
                valueDisplay: '${_acHoursPerDay.round()} hrs / day',
                icon: Icons.ac_unit,
                color: Colors.orange.shade700,
                min: 0,
                max: 16,
                divisions: 16,
                value: _acHoursPerDay,
                onChanged: (val) => setState(() => _acHoursPerDay = val),
              ),
              const SizedBox(height: 12),

              // Parameter 4: Renewable / Green Energy
              _buildSliderCard(
                title: 'Renewable / Green Energy Share',
                valueDisplay: '${_renewableEnergyPercent.round()}%',
                icon: Icons.solar_power_outlined,
                color: Colors.teal.shade700,
                min: 0,
                max: 100,
                divisions: 20,
                value: _renewableEnergyPercent,
                onChanged: (val) => setState(() => _renewableEnergyPercent = val),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Target saved! Projected to cut ${_reductionPercentage.toStringAsFixed(1)}% of your footprint.',
                      ),
                      backgroundColor: AppTheme.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_added_outlined),
                label: const Text('Save as Monthly Reduction Goal'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectionHeroCard() {
    return Card(
      elevation: 2,
      color: AppTheme.lightGreen,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Current Baseline', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    SizedBox(height: 2),
                    Text(
                      '320.0 kg/mo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward, color: AppTheme.primaryGreen),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Projected Footprint', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 2),
                    Text(
                      '${_projectedMonthlyKg.toStringAsFixed(1)} kg/mo',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProjectionStat(
                  'CO2 Reduction',
                  '-${_reductionKg.toStringAsFixed(1)} kg/mo',
                  AppTheme.primaryGreen,
                ),
                Container(height: 24, width: 1, color: Colors.grey.shade300),
                _buildProjectionStat(
                  'Reduction %',
                  '-${_reductionPercentage.toStringAsFixed(1)}%',
                  Colors.green.shade800,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProjectionStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String valueDisplay,
    required IconData icon,
    required Color color,
    required double min,
    required double max,
    required int divisions,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                Text(
                  valueDisplay,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              activeColor: color,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
