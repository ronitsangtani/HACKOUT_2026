import 'package:flutter/material.dart';
import '../../app/theme.dart';

enum NodeStatus {
  completed,
  current,
  inProgress,
  locked,
}

/// Circular stepping stone node widget representing a sustainability sector in the journey path.
class JourneyNodeWidget extends StatefulWidget {
  final String title;
  final String emoji;
  final NodeStatus status;
  final double progress; // 0.0 to 1.0 for inProgress
  final VoidCallback? onTap;

  const JourneyNodeWidget({
    super.key,
    required this.title,
    required this.emoji,
    required this.status,
    this.progress = 0.0,
    this.onTap,
  });

  @override
  State<JourneyNodeWidget> createState() => _JourneyNodeWidgetState();
}

class _JourneyNodeWidgetState extends State<JourneyNodeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.status == NodeStatus.current) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant JourneyNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == NodeStatus.current && !oldWidget.status.name.contains('current')) {
      _pulseController.repeat(reverse: true);
    } else if (widget.status != NodeStatus.current) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.status == NodeStatus.locked;
    final isCurrent = widget.status == NodeStatus.current;
    final isCompleted = widget.status == NodeStatus.completed;

    final Color nodeBg = isLocked
        ? AppTheme.duoGrayLight
        : isCompleted
            ? AppTheme.duoGreen
            : isCurrent
                ? AppTheme.duoGreen
                : AppTheme.duoBlue;

    final Color bevelColor = isLocked
        ? AppTheme.duoGray
        : isCompleted
            ? AppTheme.duoGreenDark
            : isCurrent
                ? AppTheme.duoGreenDark
                : AppTheme.duoBlueDark;

    const double size = 80.0;
    final double bevel = _isPressed ? 2.0 : 6.0;

    Widget nodeCore = GestureDetector(
      onTapDown: isLocked ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isLocked
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            },
      onTapCancel: isLocked ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: size,
        height: size,
        margin: EdgeInsets.only(top: _isPressed ? 4.0 : 0.0),
        decoration: BoxDecoration(
          color: nodeBg,
          shape: BoxShape.circle,
          border: Border.all(
            color: isLocked ? AppTheme.duoGray : Colors.white,
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: bevelColor,
              offset: Offset(0, bevel),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress ring if inProgress
            if (widget.status == NodeStatus.inProgress)
              SizedBox(
                width: size - 4,
                height: size - 4,
                child: CircularProgressIndicator(
                  value: widget.progress,
                  strokeWidth: 4,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.duoYellow),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                ),
              ),

            // Emoji / Lock Icon
            if (isLocked)
              const Icon(Icons.lock_rounded, color: AppTheme.duoGrayDark, size: 34)
            else
              Text(
                widget.emoji,
                style: const TextStyle(fontSize: 34),
              ),

            // Completed Checkmark or Crown Badge
            if (isCompleted)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppTheme.duoYellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppTheme.duoYellowDark, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );

    // If current, add pulsing halo
    if (isCurrent) {
      nodeCore = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: nodeCore,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Floating "START" banner if Current
        if (isCurrent)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.duoGreen,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: AppTheme.duoGreenDark, offset: Offset(0, 3)),
              ],
            ),
            child: const Text(
              'START',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),

        nodeCore,
        const SizedBox(height: 8),

        // Node Title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isLocked ? AppTheme.duoGrayLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.duoGray, width: 1.5),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isLocked ? AppTheme.duoGrayDark : AppTheme.duoText,
            ),
          ),
        ),
      ],
    );
  }
}
