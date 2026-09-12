import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import 'polar_bear_widget.dart';

/// Compact top status bar displaying Level, Streak, and Eco Points
/// styled like Duolingo's iconic pill counters.
class GamifiedHeader extends StatelessWidget implements PreferredSizeWidget {
  final int level;
  final int streak;
  final int ecoPoints;
  final VoidCallback? onLevelTap;
  final VoidCallback? onStreakTap;
  final VoidCallback? onPointsTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onRefresh;

  const GamifiedHeader({
    super.key,
    this.level = 4,
    this.streak = 7,
    this.ecoPoints = 1240,
    this.onLevelTap,
    this.onStreakTap,
    this.onPointsTap,
    this.onProfileTap,
    this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  Widget _buildPill({
    required Widget icon,
    required String label,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppTheme.duoGray, width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Level Pill
            _buildPill(
              icon: const Text('🌱', style: TextStyle(fontSize: 16)),
              label: 'LVL $level',
              color: AppTheme.duoGreenDark,
              bgColor: AppTheme.duoGreenLight.withValues(alpha: 0.5),
              borderColor: AppTheme.duoGreenLight,
              onTap: onLevelTap,
            ),

            // Streak Flame Pill
            _buildPill(
              icon: const Text('🔥', style: TextStyle(fontSize: 16)),
              label: '$streak',
              color: AppTheme.duoOrangeDark,
              bgColor: AppTheme.duoOrangeLight.withValues(alpha: 0.5),
              borderColor: AppTheme.duoOrangeLight,
              onTap: onStreakTap,
            ),

            // Eco Points / Gems Pill
            _buildPill(
              icon: const Text('💎', style: TextStyle(fontSize: 16)),
              label: '$ecoPoints',
              color: AppTheme.duoBlueDark,
              bgColor: AppTheme.duoBlueLight.withValues(alpha: 0.5),
              borderColor: AppTheme.duoBlueLight,
              onTap: onPointsTap,
            ),

            // Circular Profile Button with Polar Bear Mascot
            Tooltip(
              message: 'Profile',
              child: GestureDetector(
                onTap: onProfileTap ?? () => Navigator.pushNamed(context, AppRoutes.profile),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.duoBlueLight.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.duoBlue, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.duoBlueDark,
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: Center(
                        child: PolarBearWidget(
                          size: 28,
                          mood: PolarBearMood.happy,
                          showPlatform: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
