import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';
import '../../../core/widgets/achievement_badge_widget.dart';
import '../../../core/widgets/polar_bear_widget.dart';
import '../../../core/widgets/primary_game_button.dart';
import '../../auth/providers/auth_providers.dart';

/// Duolingo-styled Profile Screen featuring player header, 2x2 statistics grid,
/// collectible circular achievement badges with progression, settings access, and logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profileAsync = user != null ? ref.watch(userProfileProvider(user.uid)) : null;
    final activitiesAsync = ref.watch(userActivitiesProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);

    final name = profileAsync?.value?.name ?? user?.displayName ?? 'EcoLoop Champion';
    final points = profileAsync?.value?.ecoPoints ?? 1240;
    final streak = profileAsync?.value?.streak ?? 7;
    final level = (points / 250).floor() + 1;

    final records = activitiesAsync.value ?? [];
    final double totalCo2Logged = records.fold(0.0, (acc, r) => acc + r.co2Kg);
    final double totalCo2Saved = (totalCo2Logged * 0.45).clamp(24.6, 250.0);

    // Compute rank
    final entries = leaderboardAsync.value ?? [];
    final myEntry = entries.cast<dynamic>().firstWhere(
          (e) => e.isCurrentUser == true,
          orElse: () => null,
        );
    final rankNumber = myEntry != null ? myEntry.rank : 12;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'PROFILE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppTheme.duoSubtext),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Player Header with Polar Bear Mascot
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppTheme.duoBlueLight.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.duoBlue, width: 3),
                          ),
                          alignment: Alignment.center,
                          child: const PolarBearWidget(
                            mood: PolarBearMood.happy,
                            size: 90,
                            showPlatform: false,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.duoYellow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              'LVL $level',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.duoYellowDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.duoText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Eco Explorer • Level $level',
                      style: const TextStyle(fontSize: 13, color: AppTheme.duoSubtext, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Statistics Section (2x2 Grid)
              const Text(
                'STATISTICS',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.duoSubtext, letterSpacing: 0.8),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      emoji: '🔥',
                      value: '$streak',
                      label: 'Day Streak',
                      color: AppTheme.duoOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      emoji: '🌱',
                      value: '${totalCo2Saved.toStringAsFixed(1)} kg',
                      label: 'CO₂ Saved',
                      color: AppTheme.duoGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      emoji: '💎',
                      value: '$points',
                      label: 'Eco Points',
                      color: AppTheme.duoBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      emoji: '🏆',
                      value: '#$rankNumber',
                      label: 'League Rank',
                      color: AppTheme.duoYellow,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.leaderboard),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 3. Achievements Section
              const Text(
                'ACHIEVEMENTS',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.duoSubtext, letterSpacing: 0.8),
              ),
              const SizedBox(height: 10),

              AchievementBadgeWidget(
                title: 'First Step',
                description: 'Logged your first sustainable circular action',
                emoji: '🌱',
                currentProgress: records.isNotEmpty ? 1 : 0,
                maxProgress: 1,
                unit: 'action',
                isUnlocked: records.isNotEmpty,
              ),
              const SizedBox(height: 10),

              AchievementBadgeWidget(
                title: 'Wildfire Streak',
                description: 'Maintained a 7-day sustainable action streak',
                emoji: '🔥',
                currentProgress: streak.toDouble(),
                maxProgress: 7,
                unit: 'days',
                isUnlocked: streak >= 7,
              ),
              const SizedBox(height: 10),

              AchievementBadgeWidget(
                title: 'Green Commuter',
                description: 'Travel 50 km using transit, walking or cycling',
                emoji: '🚲',
                currentProgress: 35.0,
                maxProgress: 50.0,
                unit: 'km',
                isUnlocked: false,
              ),
              const SizedBox(height: 10),

              AchievementBadgeWidget(
                title: 'Waste Warrior',
                description: 'Divert 10 kg of recyclables from municipal landfills',
                emoji: '♻️',
                currentProgress: 6.5,
                maxProgress: 10.0,
                unit: 'kg',
                isUnlocked: false,
              ),
              const SizedBox(height: 10),

              AchievementBadgeWidget(
                title: 'Carbon Saver',
                description: 'Cut cumulative household emissions by 50 kg CO₂',
                emoji: '🌍',
                currentProgress: totalCo2Saved.clamp(0.0, 50.0),
                maxProgress: 50.0,
                unit: 'kg',
                isUnlocked: totalCo2Saved >= 50.0,
              ),

              const SizedBox(height: 32),

              // 4. Logout / Sign Out Button
              PrimaryGameButton(
                text: 'SIGN OUT',
                color: GameButtonColor.white,
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.duoGray, width: 2),
        boxShadow: const [
          BoxShadow(color: AppTheme.duoGray, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.duoText),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppTheme.duoSubtext, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}
