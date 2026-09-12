import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';
import '../models/leaderboard_entry.dart';

/// Screen displaying the community carbon reduction leaderboard.
/// Features top 3 podium, tied-rank handling, current-user highlighting,
/// pull-to-refresh and explicit reload actions.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoLoop Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
                CircularProgressIndicator(color: AppTheme.primaryGreen),
                SizedBox(height: 16),
                Text('Calculating community rankings...', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to Load Leaderboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(leaderboardProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No Rankings Available',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start logging your circular actions to climb the leaderboard!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(leaderboardProvider),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final top3 = entries.take(3).toList();

            return RefreshIndicator(
              color: AppTheme.primaryGreen,
              onRefresh: () async {
                ref.invalidate(leaderboardProvider);
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  // Methodology & Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Rankings are based on verified Eco Points and kg CO2 saved from circular actions.',
                            style: TextStyle(fontSize: 12, color: AppTheme.darkText),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Podium for Top 3
                  if (top3.isNotEmpty) _buildPodium(top3),
                  const SizedBox(height: 20),

                  const Text(
                    'Community Rankings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                  ),
                  const SizedBox(height: 10),

                  // Remaining or full list items
                  ...entries.map((entry) => _buildUserRankTile(entry)),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (top3.length > 1) _buildPodiumColumn(top3[1], 2, Colors.blueGrey, 90),
          // 1st Place
          _buildPodiumColumn(top3[0], 1, Colors.amber.shade700, 115),
          // 3rd Place
          if (top3.length > 2) _buildPodiumColumn(top3[2], 3, Colors.brown.shade400, 75),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn(LeaderboardEntry entry, int rank, Color medalColor, double height) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              CircleAvatar(
                radius: rank == 1 ? 26 : 22,
                backgroundColor: entry.isCurrentUser ? AppTheme.primaryGreen : Colors.grey.shade200,
                child: Text(
                  entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: entry.isCurrentUser ? Colors.white : AppTheme.darkText,
                    fontSize: rank == 1 ? 18 : 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: medalColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '',
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.isCurrentUser ? ' (You)' : entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.w600,
              color: entry.isCurrentUser ? AppTheme.primaryGreen : AppTheme.darkText,
            ),
          ),
          Text(
            ' pts',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
          ),
          Text(
            '- kg CO2',
            style: const TextStyle(fontSize: 9, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Container(
            height: height * 0.4,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: medalColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#',
                style: TextStyle(fontWeight: FontWeight.bold, color: medalColor, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRankTile(LeaderboardEntry entry) {
    final isMe = entry.isCurrentUser;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isMe ? 2 : 0.5,
      color: isMe ? Colors.green.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMe ? const BorderSide(color: AppTheme.primaryGreen, width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '#',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isMe ? AppTheme.primaryGreen : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: isMe ? AppTheme.primaryGreen : Colors.grey.shade200,
              child: Text(
                entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isMe ? Colors.white : AppTheme.darkText,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.name,
                style: TextStyle(
                  fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                  color: isMe ? AppTheme.primaryGreen : AppTheme.darkText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isMe)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('YOU', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(entry.city, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(width: 8),
            const Icon(Icons.local_fire_department, size: 12, color: Colors.orange),
            Text('d', style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              ' pts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.green.shade800,
              ),
            ),
            Text(
              '- kg CO2',
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
