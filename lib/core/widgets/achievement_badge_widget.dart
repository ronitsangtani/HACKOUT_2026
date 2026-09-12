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
  final int? currentPoints;
  final int? requiredPoints;

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
    this.currentPoints,
    this.requiredPoints,
  });

  @override
  Widget build(BuildContext context) {
    final double fraction = (currentProgress / maxProgress).clamp(0.0, 1.0);
    final int userPts = currentPoints ?? currentProgress.toInt();
    final int targetPts = requiredPoints ?? maxProgress.toInt();
    final double pointsFraction = targetPts > 0 ? (userPts / targetPts).clamp(0.0, 1.0) : 1.0;
    final int ptsRemaining = (targetPts - userPts).clamp(0, targetPts);

    return GestureDetector(
      onTap: () {
        onTap?.call();
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
                  // 3D Avatar Icon
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
                    child: Text(isUnlocked ? emoji : '🔒', style: const TextStyle(fontSize: 36)),
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: AppTheme.duoText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.duoSubtext,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Points Progress Breakdown Card
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
                                  '$userPts pts',
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

                        // Safe LinearProgressIndicator with rounded edges
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

                        // Status Info
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
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
                              isUnlocked
                                  ? 'Goal achieved! 🎉'
                                  : '$ptsRemaining pts needed',
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

                  // 3D Duolingo Action Button
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
