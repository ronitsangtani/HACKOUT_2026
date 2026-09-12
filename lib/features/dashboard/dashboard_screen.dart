import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/providers/ecoloop_providers.dart';
import '../../core/widgets/eco_progress_bar.dart';
import '../../core/widgets/gamified_header.dart';
import '../../core/widgets/journey_node_widget.dart';
import '../../core/widgets/primary_game_button.dart';
import '../activities/screens/add_activity_screen.dart';
import '../auth/providers/auth_providers.dart';

/// Duolingo-styled Home Screen featuring the vertical Sustainability Journey Path,
/// daily eco goal tracker, active streak counter, and dynamic category stepping stones.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  void _openActivityFlow([String? initialCategory]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityScreen(initialCategory: initialCategory),
      ),
    ).then((_) {
      ref.invalidate(userActivitiesProvider);
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        ref.invalidate(userProfileProvider(user.uid));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final userProfileAsync = user != null ? ref.watch(userProfileProvider(user.uid)) : null;
    final activitiesAsync = ref.watch(userActivitiesProvider);

    final points = userProfileAsync?.value?.ecoPoints ?? 420;
    final streak = userProfileAsync?.value?.streak ?? 7;
    final level = (points / 250).floor() + 1;

    final records = activitiesAsync.value ?? [];
    final hasTransport = records.any((r) => r.category.toLowerCase().contains('transport'));
    final hasEnergy = records.any((r) => r.category.toLowerCase().contains('energy'));
    final hasFood = records.any((r) => r.category.toLowerCase().contains('food') || r.category.toLowerCase().contains('diet'));
    final hasWaste = records.any((r) => r.category.toLowerCase().contains('waste'));
    final hasShopping = records.any((r) => r.category.toLowerCase().contains('shop') || r.category.toLowerCase().contains('circular') || r.category.toLowerCase().contains('good'));
    final hasMaster = (records.length >= 5) || (hasTransport && hasEnergy && hasFood && hasWaste && hasShopping);

    // Active focus level receives the pulsing 'START' badge
    // All other uncompleted levels are inProgress (active and fully playable simultaneously)
    final String activeFocus;
    if (!hasTransport) {
      activeFocus = 'transport';
    } else if (!hasEnergy) {
      activeFocus = 'energy';
    } else if (!hasFood) {
      activeFocus = 'food';
    } else if (!hasWaste) {
      activeFocus = 'waste';
    } else if (!hasShopping) {
      activeFocus = 'shopping';
    } else {
      activeFocus = 'master';
    }

    final NodeStatus transportStatus = hasTransport
        ? NodeStatus.completed
        : (activeFocus == 'transport' ? NodeStatus.current : NodeStatus.inProgress);
    final NodeStatus energyStatus = hasEnergy
        ? NodeStatus.completed
        : (activeFocus == 'energy' ? NodeStatus.current : NodeStatus.inProgress);
    final NodeStatus foodStatus = hasFood
        ? NodeStatus.completed
        : (activeFocus == 'food' ? NodeStatus.current : NodeStatus.inProgress);
    final NodeStatus wasteStatus = hasWaste
        ? NodeStatus.completed
        : (activeFocus == 'waste' ? NodeStatus.current : NodeStatus.inProgress);
    final NodeStatus shoppingStatus = hasShopping
        ? NodeStatus.completed
        : (activeFocus == 'shopping' ? NodeStatus.current : NodeStatus.inProgress);
    final NodeStatus lifestyleStatus = hasMaster
        ? NodeStatus.completed
        : (activeFocus == 'master' ? NodeStatus.current : NodeStatus.inProgress);

    final double transportProgress = hasTransport ? 1.0 : (records.where((r) => r.category.toLowerCase().contains('transport')).length / 2).clamp(0.25, 0.9);
    final double energyProgress = hasEnergy ? 1.0 : (records.where((r) => r.category.toLowerCase().contains('energy')).length / 2).clamp(0.25, 0.9);
    final double foodProgress = hasFood ? 1.0 : (records.where((r) => r.category.toLowerCase().contains('food') || r.category.toLowerCase().contains('diet')).length / 2).clamp(0.25, 0.9);
    final double wasteProgress = hasWaste ? 1.0 : (records.where((r) => r.category.toLowerCase().contains('waste')).length / 2).clamp(0.25, 0.9);
    final double shoppingProgress = hasShopping ? 1.0 : (records.where((r) => r.category.toLowerCase().contains('shop') || r.category.toLowerCase().contains('circular') || r.category.toLowerCase().contains('good')).length / 2).clamp(0.25, 0.9);
    final double masterProgress = hasMaster ? 1.0 : (records.length / 5).clamp(0.2, 0.9);

    // Daily Goal calculation (e.g. Target: 2.0 kg saved, actual logged count * 0.7 kg)
    final double co2SavedToday = (records.length * 0.7).clamp(0.0, 2.0);
    const double co2Goal = 2.0;
    final double goalFraction = (co2SavedToday / co2Goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: GamifiedHeader(
        level: level,
        streak: streak,
        ecoPoints: points,
        onRefresh: () {
          ref.invalidate(userActivitiesProvider);
          if (user != null) {
            ref.invalidate(userProfileProvider(user.uid));
          }
        },
      ),
      body: RefreshIndicator(
        color: AppTheme.duoGreen,
        onRefresh: () async {
          ref.invalidate(userActivitiesProvider);
          if (user != null) {
            ref.invalidate(userProfileProvider(user.uid));
            await ref.read(userProfileProvider(user.uid).future);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Daily Eco Goal Card (Duolingo Style)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.duoGray, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.duoGray, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('🎯', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text(
                              'DAILY ECO GOAL',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: AppTheme.duoSubtext,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${co2SavedToday.toStringAsFixed(1)} / ${co2Goal.toStringAsFixed(1)} kg CO₂',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: AppTheme.duoGreenDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    EcoProgressBar(
                      progress: goalFraction,
                      height: 14,
                      fillColor: AppTheme.duoGreen,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          'Keep your $streak-day eco streak burning!',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.duoOrangeDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Unit Title / League Stage Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.duoGreen,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.duoGreenDark, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SECTION 1 • CIRCULAR BASICS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasTransport ? 'Household Decarbonization' : 'Start Your Green Commute',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 3. Vertical Winding Stepping Stone Journey Path
              // Node 1: Transport (Center)
              Align(
                alignment: Alignment.center,
                child: JourneyNodeWidget(
                  title: 'Transport',
                  emoji: '🚗',
                  status: transportStatus,
                  progress: transportProgress,
                  onTap: () => _openActivityFlow('Transport'),
                ),
              ),
              _buildPathConnector(alignment: Alignment.center),

              // Node 2: Energy (Offset Right)
              Align(
                alignment: const Alignment(0.45, 0),
                child: JourneyNodeWidget(
                  title: 'Energy',
                  emoji: '⚡',
                  status: energyStatus,
                  progress: energyProgress,
                  onTap: () => _openActivityFlow('Energy'),
                ),
              ),
              _buildPathConnector(alignment: const Alignment(0.25, 0)),

              // Node 3: Food & Goods (Offset Left)
              Align(
                alignment: const Alignment(-0.45, 0),
                child: JourneyNodeWidget(
                  title: 'Diet & Food',
                  emoji: '🍽️',
                  status: foodStatus,
                  progress: foodProgress,
                  onTap: () => _openActivityFlow('Food'),
                ),
              ),
              _buildPathConnector(alignment: const Alignment(-0.25, 0)),

              // Node 4: Waste & Recycling (Center)
              Align(
                alignment: Alignment.center,
                child: JourneyNodeWidget(
                  title: 'Zero Waste',
                  emoji: '♻️',
                  status: wasteStatus,
                  progress: wasteProgress,
                  onTap: () => _openActivityFlow('Waste'),
                ),
              ),
              _buildPathConnector(alignment: Alignment.center),

              // Node 5: Circular Shopping (Offset Right)
              Align(
                alignment: const Alignment(0.45, 0),
                child: JourneyNodeWidget(
                  title: 'Circular Goods',
                  emoji: '🛍️',
                  status: shoppingStatus,
                  progress: shoppingProgress,
                  onTap: () => _openActivityFlow('Shopping'),
                ),
              ),
              _buildPathConnector(alignment: const Alignment(0.25, 0)),

              // Node 6: Master Lifestyle (Center)
              Align(
                alignment: Alignment.center,
                child: JourneyNodeWidget(
                  title: 'Eco Master',
                  emoji: '🌍',
                  status: lifestyleStatus,
                  progress: masterProgress,
                  onTap: () => _openActivityFlow(null),
                ),
              ),

              const SizedBox(height: 32),

              // 4. Daily Challenge Card (Duolingo Style)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.duoBlueLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.duoBlueLight, width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppTheme.duoBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppTheme.duoBlueDark, offset: Offset(0, 3)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text('🚶', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DAILY CHALLENGE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: AppTheme.duoBlueDark,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Walk or cycle for a short trip today',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.duoText),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.duoGreenLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '+30 🌱 REWARD',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.duoGreenDark),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Save ~1.2 kg CO₂',
                                style: TextStyle(fontSize: 11, color: AppTheme.duoSubtext, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PrimaryGameButton(
                      text: 'START',
                      color: GameButtonColor.blue,
                      height: 40,
                      fontSize: 12,
                      isFullWidth: false,
                      onPressed: () => _openActivityFlow('Transport'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 5. Quick Tools Expansion (What-If, Impact, History)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.duoGray, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CIRCULAR EXPLORATION TOOLS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: AppTheme.duoSubtext,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildToolButton(
                            icon: Icons.emoji_events_rounded,
                            label: 'Rankings',
                            color: AppTheme.duoYellowDark,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.leaderboard),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildToolButton(
                            icon: Icons.auto_graph_rounded,
                            label: 'Impact',
                            color: AppTheme.duoGreen,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.carbonImpact),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildToolButton(
                            icon: Icons.tune_rounded,
                            label: 'Simulator',
                            color: AppTheme.duoBlue,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.whatIfSimulator),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildToolButton(
                            icon: Icons.history_rounded,
                            label: 'History',
                            color: AppTheme.duoOrange,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.activityHistory),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathConnector({required Alignment alignment}) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(vertical: 2.5),
              decoration: const BoxDecoration(
                color: AppTheme.duoGray,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.duoGrayLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.duoGray, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.duoText),
            ),
          ],
        ),
      ),
    );
  }
}
