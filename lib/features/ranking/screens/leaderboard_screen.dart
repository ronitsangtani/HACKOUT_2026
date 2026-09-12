import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';
import '../../../core/widgets/primary_game_button.dart';
import '../models/leaderboard_entry.dart';

/// Duolingo-styled Leaderboard Screen with Emerald League banner,
/// top 3 celebratory podium, and current-user highlighted list.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'LEADERBOARD',
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
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 14),
                  const Text(
                    'Could not load leaderboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(err.toString(), textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.duoSubtext)),
                  const SizedBox(height: 20),
                  PrimaryGameButton(
                    text: 'RETRY',
                    isFullWidth: false,
                    color: GameButtonColor.green,
                    onPressed: () => ref.invalidate(leaderboardProvider),
                  ),
                ],
              ),
            ),
          ),
          data: (entries) {
            final list = entries.isNotEmpty ? entries : LeaderboardEntry.mockEntries;
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
          },
        ),
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
