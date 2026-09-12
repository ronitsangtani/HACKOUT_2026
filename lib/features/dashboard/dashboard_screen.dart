import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/providers/ecoloop_providers.dart';
import '../../core/providers/polar_bear_providers.dart';
import '../../core/widgets/eco_progress_bar.dart';
import '../../core/widgets/gamified_header.dart';
import '../../core/widgets/journey_node_widget.dart';
import '../../core/widgets/polar_bear_widget.dart';
import '../../core/widgets/primary_game_button.dart';
import '../activities/screens/add_activity_screen.dart';
import '../auth/providers/auth_providers.dart';

/// Duolingo-styled Home Screen featuring the original Polar Bear mascot stage,
/// dynamic carbon health condition system, vertical Sustainability Journey Path,
/// daily eco goal tracker, and interactive challenges.
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
    final bearStatus = ref.watch(polarBearStatusProvider);

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

    // Focus level for pulsing START badge
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

    // Daily Goal calculation
    final double co2SavedToday = (records.length * 0.7).clamp(0.0, 2.0);
    const double co2Goal = 2.0;
    final double goalFraction = (co2SavedToday / co2Goal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. POLAR BEAR MASCOT HERO STAGE
              _buildPolarBearStage(bearStatus),

              const SizedBox(height: 16),

              // 2. YOUR CARBON STATUS CARD
              _buildCarbonStatusCard(bearStatus),

              const SizedBox(height: 16),

              // 3. DAILY ECO GOAL CARD
              _buildDailyGoalCard(co2SavedToday, co2Goal, goalFraction, streak),

              const SizedBox(height: 20),

              // 4. UNIT / SECTION BANNER
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

              // 5. VERTICAL DUOLINGO STEPPING STONE JOURNEY PATH
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

              // Node 3: Food & Diet (Offset Left)
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

              // Node 4: Zero Waste (Center)
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

              // Node 5: Circular Goods (Offset Right)
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

              // 6. DAILY ECO CHALLENGE CARD (Featuring Polar Bear)
              _buildDailyChallengeCard(),

              const SizedBox(height: 20),

              // 7. QUICK EXPLORATION TOOLS
              _buildToolsCard(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Polar Bear Mascot Hero Stage with animated reactions and speech bubble
  Widget _buildPolarBearStage(PolarBearStatus bearStatus) {
    final bool isWarning = bearStatus.hasWarning;
    final Color stageBg = isWarning
        ? AppTheme.duoOrangeLight.withValues(alpha: 0.35)
        : AppTheme.duoBlueLight.withValues(alpha: 0.4);
    final Color stageBorder = isWarning ? AppTheme.duoOrange : AppTheme.duoBlueLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: stageBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: stageBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: stageBorder.withValues(alpha: 0.15),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Speech Bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isWarning ? AppTheme.duoOrange : AppTheme.duoBlue,
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.duoGray,
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isWarning ? '⚠️' : '❄️',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    bearStatus.speechMessage,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isWarning ? AppTheme.duoOrangeDark : AppTheme.duoText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Animated Polar Bear Widget
          PolarBearWidget.fromCondition(
            condition: bearStatus.condition,
            size: 145.0,
            showPlatform: true,
          ),

          const SizedBox(height: 4),
          // Mascot Subtitle
          Text(
            isWarning ? 'POLAR BEAR IS WARMING' : 'POLAR BEAR IS COOL & HEALTHY',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: isWarning ? AppTheme.duoOrangeDark : AppTheme.duoBlueDark,
            ),
          ),
        ],
      ),
    );
  }

  /// Carbon Status Card displaying real user emission data
  Widget _buildCarbonStatusCard(PolarBearStatus bearStatus) {
    final bool isReduced = bearStatus.weeklyReductionPct >= 0;
    final bool isWarning = bearStatus.hasWarning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWarning ? AppTheme.duoOrange : AppTheme.duoGray,
          width: 2,
        ),
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
              Text(
                'YOUR CARBON STATUS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: isWarning ? AppTheme.duoOrangeDark : AppTheme.duoSubtext,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isWarning ? AppTheme.duoOrangeLight : AppTheme.duoGreenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  bearStatus.statusHeadline,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isWarning ? AppTheme.duoOrangeDark : AppTheme.duoGreenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${bearStatus.dailyCo2Kg.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.duoText,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'CO₂ / day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.duoSubtext,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isReduced ? AppTheme.duoGreenLight : AppTheme.duoOrangeLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isReduced ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      size: 14,
                      color: isReduced ? AppTheme.duoGreenDark : AppTheme.duoOrangeDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${bearStatus.weeklyReductionPct.abs().toStringAsFixed(0)}% this week',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isReduced ? AppTheme.duoGreenDark : AppTheme.duoOrangeDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Daily Eco Goal Card
  Widget _buildDailyGoalCard(double co2SavedToday, double co2Goal, double goalFraction, int streak) {
    return Container(
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
                  Text('🎯', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'DAILY ECO GOAL',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
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
                  fontSize: 12,
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
    );
  }

  /// Daily Challenge Card
  Widget _buildDailyChallengeCard() {
    return Container(
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
                  "TODAY'S ECO CHALLENGE",
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
    );
  }

  /// Circular Exploration Tools
  Widget _buildToolsCard(BuildContext context) {
    return Container(
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
