import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/eco_progress_bar.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/reward_item.dart';

/// Duolingo-styled Rewards Screen showing live eco points, streaks, level progression,
/// collectible badges, and direct navigation to the community leaderboard.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profileAsync = user != null ? ref.watch(userProfileProvider(user.uid)) : null;

    final livePoints = profileAsync?.value?.ecoPoints ?? 420;
    final liveStreak = profileAsync?.value?.streak ?? 7;
    final reward = RewardSummary.mockSummary;
    final level = (livePoints / 250).floor() + 1;
    final nextLevelPoints = level * 250;
    final levelProgress = (livePoints % 250) / 250.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ECO REWARDS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.duoSubtext),
            tooltip: 'Refresh Rewards',
            onPressed: () {
              if (user != null) {
                ref.invalidate(userProfileProvider(user.uid));
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.duoGreen,
          onRefresh: () async {
            if (user != null) {
              ref.invalidate(userProfileProvider(user.uid));
              await ref.read(userProfileProvider(user.uid).future);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Points & Level 3D Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.duoGreen,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: AppTheme.duoGreenDark, offset: Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'LEVEL $level: ${reward.levelTitle.toUpperCase()}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                          ),
                          Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '$liveStreak-DAY STREAK',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 36)),
                          const SizedBox(width: 8),
                          Text(
                            '$livePoints',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Total Eco Points Earned',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 18),
                      // Progress to next level
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Progress to Level ${level + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('$livePoints / $nextLevelPoints pts', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          EcoProgressBar(
                            progress: levelProgress.clamp(0.05, 1.0),
                            height: 12,
                            fillColor: AppTheme.duoYellow,
                            trackColor: Colors.black12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Polar Bear Milestone Perks Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.duoBlueLight.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.duoBlueLight, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppTheme.duoBlue,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text('❄️', style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EARN GEMS & KEEP ICE COOL',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.duoBlueDark),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Complete daily stages and eco challenges to level up and unlock exclusive badges!',
                              style: TextStyle(fontSize: 11, color: AppTheme.duoText, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Badges Collection Header
                const Text(
                  'UNLOCKED MILESTONE BADGES',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.duoSubtext, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),

                // Badges Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: reward.badges.length,
                  itemBuilder: (context, index) {
                    final badge = reward.badges[index];
                    final targetPoints = [50, 150, 300, 450, 600][index % 5];
                    return GestureDetector(
                      onTap: () => _showBadgeDialog(context, badge, livePoints, targetPoints),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: badge.isUnlocked ? Colors.white : AppTheme.duoGrayLight,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: badge.isUnlocked ? AppTheme.duoYellow : AppTheme.duoGray,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: badge.isUnlocked ? AppTheme.duoYellowDark.withValues(alpha: 0.4) : AppTheme.duoGray,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              badge.icon,
                              size: 28,
                              color: badge.isUnlocked ? AppTheme.duoYellowDark : AppTheme.duoSubtext,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              badge.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: badge.isUnlocked ? AppTheme.duoText : AppTheme.duoSubtext,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              badge.isUnlocked ? 'Unlocked ✓' : 'In Progress',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badge.isUnlocked ? AppTheme.duoGreenDark : AppTheme.duoSubtext,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBadgeDialog(BuildContext context, dynamic badge, int livePoints, int targetPts) {
    final bool isUnlocked = badge.isUnlocked;
    final double pointsFraction = targetPts > 0 ? (livePoints / targetPts).clamp(0.0, 1.0) : 1.0;
    final int ptsRemaining = (targetPts - livePoints).clamp(0, targetPts);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.duoGray, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: isUnlocked ? AppTheme.duoYellowLight : AppTheme.duoGrayLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked ? AppTheme.duoYellow : AppTheme.duoGrayDark,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isUnlocked ? AppTheme.duoYellowDark.withValues(alpha: 0.4) : AppTheme.duoGray,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  badge.icon,
                  size: 36,
                  color: isUnlocked ? AppTheme.duoYellowDark : AppTheme.duoSubtext,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppTheme.duoText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.duoSubtext,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppTheme.duoGreenLight.withValues(alpha: 0.35)
                      : AppTheme.duoBlueLight.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUnlocked ? AppTheme.duoGreenLight : AppTheme.duoBlueLight,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'YOUR POINTS',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: isUnlocked ? AppTheme.duoGreenDark : AppTheme.duoBlueDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'POINTS NEEDED',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: isUnlocked ? AppTheme.duoGreenDark : AppTheme.duoBlueDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('💎', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '$livePoints pts',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppTheme.duoText,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('🎯', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '$targetPts pts',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppTheme.duoText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: isUnlocked ? 1.0 : pointsFraction,
                        minHeight: 12,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnlocked ? AppTheme.duoGreen : AppTheme.duoBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isUnlocked ? 'Unlocked ✓' : 'In Progress ⏳',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: isUnlocked ? AppTheme.duoGreenDark : AppTheme.duoOrangeDark,
                          ),
                        ),
                        Text(
                          isUnlocked ? 'Goal achieved! 🎉' : '$ptsRemaining pts needed',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: isUnlocked ? AppTheme.duoGreenDark : AppTheme.duoSubtext,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppTheme.duoGreen : AppTheme.duoBlue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isUnlocked ? AppTheme.duoGreenDark : AppTheme.duoBlueDark,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isUnlocked ? 'AWESOME!' : 'GOT IT!',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
