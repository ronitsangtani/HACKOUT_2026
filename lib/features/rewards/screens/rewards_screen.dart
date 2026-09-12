import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/reward_item.dart';

/// Rewards Screen (Tab 3 in Bottom Navigation).
/// Shows live user eco points, streaks, badges, completed action logs,
/// with direct access to the community leaderboard and pull-to-refresh.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profileAsync = user != null ? ref.watch(userProfileProvider(user.uid)) : null;

    final livePoints = profileAsync?.value?.ecoPoints ?? 420;
    final liveStreak = profileAsync?.value?.streak ?? 5;
    final reward = RewardSummary.mockSummary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Rewards & Milestones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
          color: AppTheme.primaryGreen,
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
                // Points & Level Banner
                Card(
                  color: AppTheme.primaryGreen,
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Level ${reward.level}: ${reward.levelTitle}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '$liveStreak-Day Streak',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$livePoints',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const Text(
                          'Total Eco Points Earned',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        // Progress to next level
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Progress to Level 4', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                Text('$livePoints / 800 pts', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (livePoints / 800).clamp(0.0, 1.0),
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Leaderboard Direct Navigation Card
                Card(
                  color: Colors.amber.shade50,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.amber.shade200),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.leaderboard),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.amber.shade100,
                            radius: 20,
                            child: Icon(Icons.emoji_events, color: Colors.amber.shade800, size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Community Leaderboard',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkText),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'View your community ranking & CO2 savings',
                                  style: TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Badges Grid Section
                const Text(
                  'Circular Badges & Achievements',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                ),
                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: reward.badges.length,
                  itemBuilder: (context, index) {
                    final badge = reward.badges[index];
                    return Card(
                      color: badge.isUnlocked ? Colors.white : Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: badge.isUnlocked ? AppTheme.lightGreen : Colors.grey.shade300,
                              child: Icon(
                                badge.icon,
                                color: badge.isUnlocked ? AppTheme.primaryGreen : Colors.grey.shade600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              badge.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: badge.isUnlocked ? AppTheme.darkText : Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              badge.isUnlocked ? (badge.earnedDate ?? 'Earned') : 'Locked',
                              style: TextStyle(
                                fontSize: 9,
                                color: badge.isUnlocked ? Colors.green.shade800 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Completed Actions Log
                const Text(
                  'Recent Completed Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                ),
                const SizedBox(height: 10),

                ...reward.recentActions.map((action) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        dense: true,
                        leading: const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.lightGreen,
                          child: Icon(Icons.check, size: 16, color: AppTheme.primaryGreen),
                        ),
                        title: Text(action.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text(action.date, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${action.points} pts',
                            style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
