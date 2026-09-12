import 'package:flutter/material.dart';
import '../../app/theme.dart';
import 'eco_progress_bar.dart';

/// Collectible circular achievement badge with progression tracking.
class AchievementBadgeWidget extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final double currentProgress;
  final double maxProgress;
  final String unit;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementBadgeWidget({
    super.key,
    required this.title,
    required this.description,
    required this.emoji,
    required this.currentProgress,
    required this.maxProgress,
    required this.unit,
    this.isUnlocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double fraction = (currentProgress / maxProgress).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        onTap?.call();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppTheme.duoYellowLight : AppTheme.duoGrayLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isUnlocked ? AppTheme.duoYellow : AppTheme.duoGrayDark,
                      width: 3,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(isUnlocked ? emoji : '🔒', style: const TextStyle(fontSize: 34)),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.duoSubtext, fontSize: 14),
                ),
                const SizedBox(height: 16),
                EcoProgressBar(
                  progress: fraction,
                  height: 12,
                  fillColor: isUnlocked ? AppTheme.duoYellow : AppTheme.duoGreen,
                ),
                const SizedBox(height: 8),
                Text(
                  '${currentProgress.toInt()} / ${maxProgress.toInt()} $unit',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.duoText),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.duoGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('AWESOME!', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnlocked ? AppTheme.duoYellow : AppTheme.duoGray,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked ? AppTheme.duoYellowDark.withValues(alpha: 0.5) : AppTheme.duoGray,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Badge Icon
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isUnlocked ? AppTheme.duoYellowLight : AppTheme.duoGrayLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? AppTheme.duoYellow : AppTheme.duoGrayDark,
                  width: 2.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                isUnlocked ? emoji : '🔒',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 14),

            // Content & Progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isUnlocked ? AppTheme.duoText : AppTheme.duoSubtext,
                        ),
                      ),
                      if (isUnlocked)
                        const Icon(Icons.verified, color: AppTheme.duoYellow, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: AppTheme.duoSubtext),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  EcoProgressBar(
                    progress: fraction,
                    height: 8,
                    fillColor: isUnlocked ? AppTheme.duoYellow : AppTheme.duoGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
