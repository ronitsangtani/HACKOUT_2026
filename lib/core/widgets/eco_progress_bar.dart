import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Rounded glossy progress bar styled after Duolingo's lesson progress indicator.
class EcoProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color fillColor;
  final Color trackColor;

  const EcoProgressBar({
    super.key,
    required this.progress,
    this.height = 14,
    this.fillColor = AppTheme.duoGreen,
    this.trackColor = AppTheme.duoGray,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Stack(
            children: [
              // Animated Fill
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: clampedProgress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return Container(
                    width: totalWidth * val,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                    child: Stack(
                      children: [
                        // Subtle Gloss Highlight at top
                        Positioned(
                          top: 2,
                          left: 4,
                          right: 4,
                          height: height * 0.35,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(height / 4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
