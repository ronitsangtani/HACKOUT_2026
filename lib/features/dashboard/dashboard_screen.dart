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

  void _showLockedDialog(String sectorName, String prereq) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppTheme.duoGrayLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.lock_rounded, color: AppTheme.duoGrayDark, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              '$sectorName Locked',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ],
        ),
        content: Text(
          'Complete $prereq to unlock the $sectorName sustainability sector!',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.duoSubtext, fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          PrimaryGameButton(
            text: 'GOT IT',
            color: GameButtonColor.green,
            height: 48,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
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
    final hasFood = records.any((r) => r.category.toLowerCase().contains('food') || r.category.toLowerCase().contains('shopping'));
    final hasWaste = records.any((r) => r.category.toLowerCase().contains('waste'));

    // Compute status of nodes along the path
    final NodeStatus transportStatus = hasTransport ? NodeStatus.completed : NodeStatus.current;
    final NodeStatus energyStatus = hasEnergy
        ? NodeStatus.completed
        : hasTransport
            ? NodeStatus.current
            : NodeStatus.locked;
    final NodeStatus foodStatus = hasFood
        ? NodeStatus.completed
        : (hasTransport && hasEnergy)
            ? NodeStatus.current
            : NodeStatus.locked;
    final NodeStatus wasteStatus = hasWaste
        ? NodeStatus.completed
        : (hasTransport && hasEnergy && hasFood)
            ? NodeStatus.current
            : NodeStatus.locked;
    final NodeStatus shoppingStatus = (hasTransport && hasEnergy && hasFood && hasWaste)
        ? NodeStatus.current
        : NodeStatus.locked;
    final NodeStatus lifestyleStatus = (hasTransport && hasEnergy && hasFood && hasWaste && records.length >= 5)
        ? NodeStatus.current
        : NodeStatus.locked;

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
                  onTap: energyStatus == NodeStatus.locked
                      ? () => _showLockedDialog('Energy', 'Transport')
                      : () => _openActivityFlow('Energy'),
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
                  onTap: foodStatus == NodeStatus.locked
                      ? () => _showLockedDialog('Diet & Food', 'Energy')
                      : () => _openActivityFlow('Shopping'),
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
                  onTap: wasteStatus == NodeStatus.locked
                      ? () => _showLockedDialog('Zero Waste', 'Diet & Food')
                      : () => _openActivityFlow('Waste'),
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
                  onTap: shoppingStatus == NodeStatus.locked
                      ? () => _showLockedDialog('Circular Goods', 'Zero Waste')
                      : () => _openActivityFlow('Shopping'),
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
                  onTap: lifestyleStatus == NodeStatus.locked
                      ? () => _showLockedDialog('Eco Master', 'all foundational sectors')
                      : () => _openActivityFlow('Transport'),
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
