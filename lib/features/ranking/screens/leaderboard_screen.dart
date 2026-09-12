import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';
import '../models/leaderboard_entry.dart';

import '../../auth/providers/auth_providers.dart';

/// Duolingo-styled Leaderboard Screen with Emerald League banner,
/// top 3 celebratory podium, and current-user highlighted list.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final user = ref.watch(authStateProvider).value;
    final profile = user != null ? ref.watch(userProfileProvider(user.uid)).value : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '🏆 ECO LEAGUE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.duoSubtext),
            tooltip: 'Refresh Rankings',
            onPressed: () => ref.invalidate(leaderboardProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: leaderboardAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.duoGreen),
                SizedBox(height: 16),
                Text('Calculating league rankings...', style: TextStyle(color: AppTheme.duoSubtext, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          error: (err, stack) => _buildLeaderboardView(
            context: context,
            ref: ref,
            rawEntries: LeaderboardEntry.mockEntries,
            user: user,
            profilePoints: profile?.ecoPoints,
            profileStreak: profile?.streak,
            profileName: profile?.name,
            profileCity: profile?.city,
            isOffline: true,
          ),
          data: (entries) => _buildLeaderboardView(
            context: context,
            ref: ref,
            rawEntries: entries.isNotEmpty ? entries : LeaderboardEntry.mockEntries,
            user: user,
            profilePoints: profile?.ecoPoints,
            profileStreak: profile?.streak,
            profileName: profile?.name,
            profileCity: profile?.city,
            isOffline: false,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardView({
    required BuildContext context,
    required WidgetRef ref,
    required List<LeaderboardEntry> rawEntries,
    required dynamic user,
    required int? profilePoints,
    required int? profileStreak,
    required String? profileName,
    required String? profileCity,
    required bool isOffline,
  }) {
    List<LeaderboardEntry> list = List.from(rawEntries);

    // Personalize with current user if not present or to ensure exact points match
    final bool hasCurrentUser = list.any((e) => e.isCurrentUser || (user != null && e.uid == user.uid));
    if (!hasCurrentUser && user != null) {
      final int myPoints = profilePoints ?? 420;
      final int myStreak = profileStreak ?? 3;
      final String myName = (profileName != null && profileName.isNotEmpty)
          ? profileName
          : (user.displayName != null && user.displayName.isNotEmpty)
              ? user.displayName
              : 'You';

      list.add(LeaderboardEntry(
        rank: 4,
        uid: user.uid,
        name: myName,
        city: profileCity?.isNotEmpty == true ? profileCity! : 'Bengaluru',
        ecoPoints: myPoints,
        co2SavedKg: (myPoints * 0.12).clamp(0.0, 999.0),
        streak: myStreak,
        isCurrentUser: true,
      ));

      list.sort((a, b) => b.ecoPoints.compareTo(a.ecoPoints));

      int rank = 1;
      final List<LeaderboardEntry> ranked = [];
      for (int i = 0; i < list.length; i++) {
        if (i > 0 && list[i].ecoPoints < list[i - 1].ecoPoints) {
          rank = i + 1;
        }
        final e = list[i];
        ranked.add(LeaderboardEntry(
          rank: rank,
          uid: e.uid,
          name: e.name,
          city: e.city,
          ecoPoints: e.ecoPoints,
          co2SavedKg: e.co2SavedKg,
          streak: e.streak,
          isCurrentUser: e.isCurrentUser || (user != null && e.uid == user.uid),
        ));
      }
      list = ranked;
    }

    final top3 = list.take(3).toList();
    final rest = list.skip(3).toList();
    final currentUserEntry = list.cast<LeaderboardEntry?>().firstWhere(
          (e) => e?.isCurrentUser == true,
          orElse: () => null,
        );

    return RefreshIndicator(
      color: AppTheme.duoGreen,
      onRefresh: () async {
        ref.invalidate(leaderboardProvider);
        await ref.read(leaderboardProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. League Tier Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.duoGreenLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.duoGreen, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppTheme.duoGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppTheme.duoGreenDark, offset: Offset(0, 3)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('💎', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMERALD LEAGUE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppTheme.duoGreenDark,
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Top 10 advance to Ruby League • 2d left',
                        style: TextStyle(fontSize: 12, color: AppTheme.duoSubtext, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Top 3 Podium
          if (top3.length >= 3) ...[
            _buildPodium(top3),
            const SizedBox(height: 24),
          ],

                  // 3. Current User Rank Banner (if outside top 3)
                  if (currentUserEntry != null && currentUserEntry.rank > 3) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.duoGreenLight.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.duoGreen, width: 2.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.duoGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '#${currentUserEntry.rank}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('YOUR RANK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.duoGreenDark)),
                          const Spacer(),
                          Text(
                            '${currentUserEntry.ecoPoints} 🌱',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.duoGreenDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text(
                    'LEAGUE STANDINGS',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.duoSubtext, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 10),

                  // 4. Rankings List (#4 to #50)
                  ...rest.map((entry) => _buildLeaderboardTile(entry)),
                  const SizedBox(height: 20),
                ],
              ),
            );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    final first = top3[0];
    final second = top3[1];
    final third = top3[2];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place (Silver)
        _buildPodiumStep(
          entry: second,
          rankNumber: '2',
          medalEmoji: '🥈',
          height: 130,
          color: const Color(0xFFC0C0C0),
          darkColor: const Color(0xFFA0A0A0),
        ),
        const SizedBox(width: 8),

        // 1st Place (Gold, Center Tallest)
        _buildPodiumStep(
          entry: first,
          rankNumber: '1',
          medalEmoji: '👑',
          height: 165,
          color: AppTheme.duoYellow,
          darkColor: AppTheme.duoYellowDark,
          isFirst: true,
        ),
        const SizedBox(width: 8),

        // 3rd Place (Bronze)
        _buildPodiumStep(
          entry: third,
          rankNumber: '3',
          medalEmoji: '🥉',
          height: 110,
          color: const Color(0xFFCD7F32),
          darkColor: const Color(0xFFA56526),
        ),
      ],
    );
  }

  Widget _buildPodiumStep({
    required LeaderboardEntry entry,
    required String rankNumber,
    required String medalEmoji,
    required double height,
    required Color color,
    required Color darkColor,
    bool isFirst = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Medal / Crown
          Text(medalEmoji, style: TextStyle(fontSize: isFirst ? 28 : 22)),
          const SizedBox(height: 4),

          // User Avatar Circle
          CircleAvatar(
            radius: isFirst ? 28 : 22,
            backgroundColor: color,
            child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: isFirst ? 20 : 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // User Name
          Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.duoText),
          ),
          const SizedBox(height: 2),

          // Points
          Text(
            '${entry.ecoPoints} 🌱',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: isFirst ? AppTheme.duoYellowDark : AppTheme.duoSubtext,
            ),
          ),
          const SizedBox(height: 6),

          // 3D Podium Block
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(color: darkColor, offset: const Offset(0, 4)),
              ],
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              rankNumber,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry) {
    final isMe = entry.isCurrentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.duoGreenLight.withValues(alpha: 0.35) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? AppTheme.duoGreen : AppTheme.duoGray,
          width: isMe ? 2.5 : 2,
        ),
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: isMe ? AppTheme.duoGreenDark : AppTheme.duoSubtext,
              ),
            ),
          ),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: isMe ? AppTheme.duoGreen : AppTheme.duoGrayLight,
            child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: isMe ? Colors.white : AppTheme.duoText,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and City
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: isMe ? AppTheme.duoGreenDark : AppTheme.duoText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.duoGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('YOU', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ],
                ),
                Text(
                  entry.city,
                  style: const TextStyle(fontSize: 11, color: AppTheme.duoSubtext),
                ),
              ],
            ),
          ),

          // Eco Points Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.duoGreenLight : AppTheme.duoGrayLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${entry.ecoPoints} 🌱',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: isMe ? AppTheme.duoGreenDark : AppTheme.duoText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
