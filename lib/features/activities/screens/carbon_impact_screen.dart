import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';

/// Screen detailing the user's total carbon impact, category breakdowns, and weekly trends.
class CarbonImpactScreen extends ConsumerWidget {
  const CarbonImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Impact Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Impact',
            onPressed: () => ref.refresh(userActivitiesProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryGreen,
          onRefresh: () async => ref.refresh(userActivitiesProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // 1. Total CO2 Hero Banner
              Card(
                color: AppTheme.primaryGreen,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Total Monthly Impact (Mock)',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '248.5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const Text(
                        'kg CO2e emitted this month',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '🎉 18% lower than regional city average (305 kg)',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Category Contribution Breakdown
              const Text(
                'Category Contributions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
              ),
              const SizedBox(height: 12),

              _buildContributionCard(
                title: 'Transport Emissions',
                percentage: '45%',
                value: '111.8 kg CO2e',
                icon: Icons.directions_car_outlined,
                color: Colors.blue.shade700,
                description: 'Dominant factor: Daily solo car commutes.',
              ),
              const SizedBox(height: 10),
              _buildContributionCard(
                title: 'Household Energy',
                percentage: '30%',
                value: '74.5 kg CO2e',
                icon: Icons.bolt_outlined,
                color: Colors.orange.shade700,
                description: 'Grid electricity and air conditioning usage.',
              ),
              const SizedBox(height: 10),
              _buildContributionCard(
                title: 'Shopping & Goods',
                percentage: '15%',
                value: '37.3 kg CO2e',
                icon: Icons.shopping_bag_outlined,
                color: Colors.purple.shade700,
                description: 'Embodied carbon from packaged products & groceries.',
              ),
              const SizedBox(height: 10),
              _buildContributionCard(
                title: 'Waste & Landfill',
                percentage: '10%',
                value: '24.9 kg CO2e',
                icon: Icons.delete_outline,
                color: Colors.teal.shade700,
                description: 'Methane impact from unsegregated solid waste.',
              ),

              const SizedBox(height: 24),

              // 3. Weekly Trend Placeholder
              const Text(
                'Weekly Footprint Trend',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mon - Sun (Daily kg CO2e)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text('Avg: 12.1 kg/day', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Mock Bar Chart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTrendBar('Mon', 14.5, 0.72),
                          _buildTrendBar('Tue', 12.0, 0.60),
                          _buildTrendBar('Wed', 15.8, 0.79),
                          _buildTrendBar('Thu', 11.2, 0.56),
                          _buildTrendBar('Fri', 13.4, 0.67),
                          _buildTrendBar('Sat', 9.2, 0.46),
                          _buildTrendBar('Sun', 8.5, 0.42),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  static Widget _buildContributionCard({
    required String title,
    required String percentage,
    required String value,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(percentage, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTrendBar(String day, double kg, double heightFactor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(kg.toStringAsFixed(1), style: const TextStyle(fontSize: 10, color: Colors.black54)),
        const SizedBox(height: 6),
        Container(
          width: 22,
          height: 90 * heightFactor,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
