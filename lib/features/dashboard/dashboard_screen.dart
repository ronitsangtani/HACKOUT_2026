import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/providers/ecoloop_providers.dart';
import '../auth/providers/auth_providers.dart';

/// Dashboard/Home screen displaying live carbon footprint summary, category breakdown,
/// daily recommendations, quick access to circular tools, and full pull-to-refresh capabilities.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final userProfileAsync = user != null ? ref.watch(userProfileProvider(user.uid)) : null;
    final activitiesAsync = ref.watch(userActivitiesProvider);
    final recommendationsAsync = ref.watch(circularRecommendationsProvider);

    final displayName = userProfileAsync?.value?.name ?? user?.displayName ?? 'EcoLoop Member';
    final livePoints = userProfileAsync?.value?.ecoPoints ?? 420;
    final liveStreak = userProfileAsync?.value?.streak ?? 7;

    // Calculate dynamic carbon stats from logged activities
    final records = activitiesAsync.value ?? [];
    final double todayFootprint;
    final double weeklyTotal;
    final double transportKg;
    final double energyKg;
    final double shoppingKg;
    final double wasteKg;

    if (records.isNotEmpty) {
      todayFootprint = records.fold<double>(0.0, (acc, r) => acc + r.co2Kg);
      weeklyTotal = todayFootprint * 1.5;
      transportKg = records.where((r) => r.category.toLowerCase().contains('transport')).fold<double>(0.0, (acc, r) => acc + r.co2Kg);
      energyKg = records.where((r) => r.category.toLowerCase().contains('energy')).fold<double>(0.0, (acc, r) => acc + r.co2Kg);
      shoppingKg = records.where((r) => r.category.toLowerCase().contains('shopping')).fold<double>(0.0, (acc, r) => acc + r.co2Kg);
      wasteKg = records.where((r) => r.category.toLowerCase().contains('waste')).fold<double>(0.0, (acc, r) => acc + r.co2Kg);
    } else {
      todayFootprint = 14.2;
      weeklyTotal = 84.6;
      transportKg = 6.4;
      energyKg = 4.3;
      shoppingKg = 2.1;
      wasteKg = 1.4;
    }

    final totalCat = (transportKg + energyKg + shoppingKg + wasteKg) > 0 ? (transportKg + energyKg + shoppingKg + wasteKg) : 1.0;

    // Today's dynamic recommendation
    final recList = recommendationsAsync.value ?? [];
    final todayRecTitle = recList.isNotEmpty ? recList.first.title : 'Switch to Cold Water Laundry';
    final todayRecDesc = recList.isNotEmpty ? recList.first.description : 'Heating water accounts for ~90% of washing machine energy. Save ~18 kg CO2 and ₹320 this month.';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EcoLoop',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
            onPressed: () {
              if (user != null) {
                ref.invalidate(userProfileProvider(user.uid));
              }
              ref.invalidate(userActivitiesProvider);
              ref.invalidate(circularRecommendationsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new alerts. Your streak is active!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryGreen,
          onRefresh: () async {
            if (user != null) {
              ref.invalidate(userProfileProvider(user.uid));
            }
            ref.invalidate(userActivitiesProvider);
            ref.invalidate(circularRecommendationsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. User Greeting & Streak Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good day, $displayName',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Consumer Carbon Loop Overview',
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    // Streak Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.orange.shade800, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$liveStreak days',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Current Carbon Footprint Hero Card
                _buildCarbonHeroCard(
                  context,
                  todayFootprint: todayFootprint.toStringAsFixed(1),
                  weeklyTotal: '${weeklyTotal.toStringAsFixed(1)} kg',
                  ecoPoints: '$livePoints pts',
                ),

                const SizedBox(height: 18),

                // 3. Category Breakdown Card
                _buildCategoryBreakdownCard(
                  context,
                  transportKg: transportKg,
                  energyKg: energyKg,
                  shoppingKg: shoppingKg,
                  wasteKg: wasteKg,
                  totalKg: totalCat,
                ),

                const SizedBox(height: 18),

                // 4. Today's Recommended Circular Action
                _buildTodayActionCard(context, title: todayRecTitle, desc: todayRecDesc),

                const SizedBox(height: 18),

                // 5. Explore Circular Tools Navigation Row
                const Text(
                  'Explore Circular Tools',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildToolCard(
                        context,
                        title: 'What-If Simulator',
                        subtitle: 'Simulate changes',
                        icon: Icons.tune,
                        color: Colors.teal.shade700,
                        bgColor: Colors.teal.shade50,
                        route: AppRoutes.whatIf,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildToolCard(
                        context,
                        title: 'Recycling Hub',
                        subtitle: 'Find drop-offs',
                        icon: Icons.recycling,
                        color: Colors.green.shade800,
                        bgColor: Colors.green.shade50,
                        route: AppRoutes.recycling,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildToolCard(
                        context,
                        title: 'Leaderboard',
                        subtitle: 'Ranks & stats',
                        icon: Icons.emoji_events,
                        color: Colors.amber.shade800,
                        bgColor: Colors.amber.shade50,
                        route: AppRoutes.leaderboard,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addActivity);
        },
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCarbonHeroCard(
    BuildContext context, {
    required String todayFootprint,
    required String weeklyTotal,
    required String ecoPoints,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppTheme.primaryGreen,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Carbon Footprint',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.greenAccent, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '-12% vs last week',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  todayFootprint,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'kg CO2e',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.carbonImpact);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('View Impact', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Weekly Total', weeklyTotal),
                _buildStatItem('Eco Points', ecoPoints),
                _buildStatItem('Monthly Est.', '342 kg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildCategoryBreakdownCard(
    BuildContext context, {
    required double transportKg,
    required double energyKg,
    required double shoppingKg,
    required double wasteKg,
    required double totalKg,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category Breakdown',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.carbonImpact),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                  child: const Text('Details', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCategoryRow('Transport', (transportKg / totalKg).clamp(0.0, 1.0), '${transportKg.toStringAsFixed(1)} kg', Colors.blue.shade700),
            const SizedBox(height: 8),
            _buildCategoryRow('Energy', (energyKg / totalKg).clamp(0.0, 1.0), '${energyKg.toStringAsFixed(1)} kg', Colors.orange.shade700),
            const SizedBox(height: 8),
            _buildCategoryRow('Shopping', (shoppingKg / totalKg).clamp(0.0, 1.0), '${shoppingKg.toStringAsFixed(1)} kg', Colors.purple.shade700),
            const SizedBox(height: 8),
            _buildCategoryRow('Waste', (wasteKg / totalKg).clamp(0.0, 1.0), '${wasteKg.toStringAsFixed(1)} kg', Colors.teal.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String title, double factor, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text(amount, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: factor,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayActionCard(BuildContext context, {required String title, required String desc}) {
    return Card(
      color: AppTheme.lightGreen,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates_outlined, color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Recommended Action',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.recommendations);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('View Circular Actions', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String route,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: bgColor,
                radius: 16,
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
