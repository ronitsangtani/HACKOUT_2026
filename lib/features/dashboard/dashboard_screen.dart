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
    final hasShopping = records.any((r) => r.category.toLowerCase().contains('shop') || r.category.toLowerCase().contains('circular') || r.category.toLowerCase().contains('good'));

    // Focus level for pulsing START badge (across the 4 active stages)
    final String activeFocus;
    if (!hasTransport) {
      activeFocus = 'transport';
    } else if (!hasEnergy) {
      activeFocus = 'energy';
    } else if (!hasFood) {
      activeFocus = 'food';
    } else {
      activeFocus = 'shopping';
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
    final NodeStatus shoppingStatus = hasShopping
        ? NodeStatus.completed
        : (activeFocus == 'shopping' ? NodeStatus.current : NodeStatus.inProgress);

    final double transportProgress = hasTransport ? 1.0 : (records.where((r) => r.category.toLowerCase().contains('transport')).length / 2).clamp(0.25, 0.9);
    final double energyProgress = hasEnergy ? 1.0 : (records.where((r) => r.category.toLowerCase().contains('energy')).length / 2).clamp(0.25, 0.9);
    final double foodProgress = hasFood ? 1.0 : (records.where((r) => r.category.toLowerCase().contains('food') || r.category.toLowerCase().contains('diet')).length / 2).clamp(0.25, 0.9);
    final double shoppingProgress = hasShopping ? 1.0 : (records.where((r) => r.category.toLowerCase().contains('shop') || r.category.toLowerCase().contains('circular') || r.category.toLowerCase().contains('good')).length / 2).clamp(0.25, 0.9);

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
        onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
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
              // 1. "START WITH CIRCULAR BASICS" — PRIMARY PROMINENT SECTION
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

              const SizedBox(height: 16),

              // POLAR BEAR MASCOT HERO STAGE
              _buildPolarBearStage(bearStatus),

              const SizedBox(height: 16),

              // YOUR CARBON STATUS CARD
              _buildCarbonStatusCard(bearStatus),

              const SizedBox(height: 24),

              // VERTICAL DUOLINGO STEPPING STONE JOURNEY PATH (4 STAGES)
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
              _buildPathConnector(alignment: const Alignment(0.22, 0)),

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
              _buildPathConnector(alignment: const Alignment(0.0, 0)),

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
              _buildPathConnector(alignment: const Alignment(-0.22, 0)),

              // Node 4: Circular Goods (Center)
              Align(
                alignment: Alignment.center,
                child: JourneyNodeWidget(
                  title: 'Circular Goods',
                  emoji: '🛍️',
                  status: shoppingStatus,
                  progress: shoppingProgress,
                  onTap: () => _openActivityFlow('Shopping'),
                ),
              ),

              const SizedBox(height: 28),

              // 2. DAILY ECO GOAL (Placed after Circular Basics, compact & gamified)
              _buildDailyGoalCard(co2SavedToday, co2Goal, goalFraction, streak),

              const SizedBox(height: 24),

              // 3. EXTRA CHALLENGES (Glitch-free, responsive)
              _buildExtraChallengesSection(),

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

  /// Extra Challenges Section (Glitch-free, responsive with Wrap and flexible padding)
  Widget _buildExtraChallengesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'EXTRA CHALLENGES',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: AppTheme.duoSubtext,
                letterSpacing: 0.8,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.duoBlueLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '2 ACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.duoBlueDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Challenge 1: Eco Commute
        _buildChallengeCard(
          emoji: '🚶',
          title: "TODAY'S ECO COMMUTE",
          description: 'Walk or cycle for a short trip today',
          rewardBadge: '+30 🌱 REWARD',
          co2Badge: 'Save ~1.2 kg CO₂',
          buttonColor: GameButtonColor.blue,
          onStart: () => _openActivityFlow('Transport'),
        ),
        const SizedBox(height: 12),
        // Challenge 2: Green Diet
        _buildChallengeCard(
          emoji: '🥗',
          title: 'GREEN DIET TARGET',
          description: 'Choose a delicious plant-based meal today',
          rewardBadge: '+25 🌱 REWARD',
          co2Badge: 'Save ~2.0 kg CO₂',
          buttonColor: GameButtonColor.green,
          onStart: () => _openActivityFlow('Food'),
        ),
      ],
    );
  }

  Widget _buildChallengeCard({
    required String emoji,
    required String title,
    required String description,
    required String rewardBadge,
    required String co2Badge,
    required GameButtonColor buttonColor,
    required VoidCallback onStart,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.duoGray, width: 2),
        boxShadow: const [
          BoxShadow(color: AppTheme.duoGray, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.duoBlueLight.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                    color: AppTheme.duoSubtext,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppTheme.duoText,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.duoGreenLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rewardBadge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.duoGreenDark,
                        ),
                      ),
                    ),
                    Text(
                      co2Badge,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppTheme.duoSubtext,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PrimaryGameButton(
            text: 'START',
            color: buttonColor,
            height: 38,
            fontSize: 11,
            isFullWidth: false,
            onPressed: onStart,
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
}
