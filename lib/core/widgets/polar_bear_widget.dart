import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../providers/polar_bear_providers.dart';

enum PolarBearMood {
  happy,
  moderate,
  worried,
  critical,
  celebrating,
}

/// Dynamic, animated vector-drawn Polar Bear mascot for EcoLoop.
/// Renders a cute, rounded, expressive polar bear on an ice platform
/// with breathing, waving, blinking, and mood-dependent environmental effects.
class PolarBearWidget extends StatefulWidget {
  final PolarBearMood mood;
  final double size;
  final String? speechText;
  final VoidCallback? onTap;
  final bool showSpeechBubble;
  final bool showPlatform;

  const PolarBearWidget({
    super.key,
    this.mood = PolarBearMood.happy,
    this.size = 140.0,
    this.speechText,
    this.onTap,
    this.showSpeechBubble = false,
    this.showPlatform = true,
  });

  factory PolarBearWidget.fromCondition({
    Key? key,
    required PolarBearCondition condition,
    double size = 140.0,
    String? speechText,
    VoidCallback? onTap,
    bool showSpeechBubble = false,
    bool showPlatform = true,
  }) {
    final PolarBearMood mood;
    switch (condition) {
      case PolarBearCondition.healthy:
        mood = PolarBearMood.happy;
        break;
      case PolarBearCondition.moderate:
        mood = PolarBearMood.moderate;
        break;
      case PolarBearCondition.highCarbon:
        mood = PolarBearMood.worried;
        break;
      case PolarBearCondition.critical:
        mood = PolarBearMood.critical;
        break;
    }
    return PolarBearWidget(
      key: key,
      mood: mood,
      size: size,
      speechText: speechText,
      onTap: onTap,
      showSpeechBubble: showSpeechBubble,
      showPlatform: showPlatform,
    );
  }

  @override
  State<PolarBearWidget> createState() => _PolarBearWidgetState();
}

class _PolarBearWidgetState extends State<PolarBearWidget> with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _blinkController;
  late AnimationController _waveController;
  late AnimationController _celebrateController;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();

    // 1. Idle breathing loop (gentle bobbing)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // 2. Blinking controller
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scheduleNextBlink();

    // 3. Paw waving loop
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // 4. Celebration jumping loop
    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    if (widget.mood == PolarBearMood.celebrating) {
      _celebrateController.repeat(reverse: true);
    }
  }

  void _scheduleNextBlink() {
    _blinkTimer?.cancel();
    if (!mounted) return;
    _blinkTimer = Timer(
      Duration(milliseconds: 2500 + math.Random().nextInt(2000)),
      () async {
        if (!mounted) return;
        try {
          await _blinkController.forward();
          if (!mounted) return;
          await _blinkController.reverse();
        } catch (_) {}
        _scheduleNextBlink();
      },
    );
  }

  @override
  void didUpdateWidget(covariant PolarBearWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == PolarBearMood.celebrating) {
      if (!_celebrateController.isAnimating) {
        _celebrateController.repeat(reverse: true);
      }
    } else {
      if (_celebrateController.isAnimating) {
        _celebrateController.stop();
        _celebrateController.reset();
      }
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _idleController.dispose();
    _blinkController.dispose();
    _waveController.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Trigger celebratory hop on tap
        if (!_celebrateController.isAnimating) {
          _celebrateController.forward().then((_) {
            if (mounted && widget.mood != PolarBearMood.celebrating) {
              _celebrateController.reverse();
            }
          });
        }
        widget.onTap?.call();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Optional Duolingo Speech Bubble
          if (widget.showSpeechBubble && widget.speechText != null && widget.speechText!.isNotEmpty)
            _buildSpeechBubble(widget.speechText!),

          // Animated Polar Bear Figure + Ice Floe Platform
          AnimatedBuilder(
            animation: Listenable.merge([
              _idleController,
              _blinkController,
              _waveController,
              _celebrateController,
            ]),
            builder: (context, _) {
              // Breathing displacement
              final double breathingY = math.sin(_idleController.value * math.pi) * 3.5;
              final double jumpY = _celebrateController.isAnimating
                  ? -_celebrateController.value * 14.0
                  : 0.0;
              final double waveAngle = math.sin(_waveController.value * math.pi) * 0.25;
              final double blinkVal = _blinkController.value;

              return Transform.translate(
                offset: Offset(0, breathingY + jumpY),
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _PolarBearPainter(
                    mood: widget.mood,
                    waveAngle: waveAngle,
                    blinkVal: blinkVal,
                    idleVal: _idleController.value,
                    showPlatform: widget.showPlatform,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(String text) {
    final bool isWarning = widget.mood == PolarBearMood.worried || widget.mood == PolarBearMood.critical;
    final Color bubbleBorder = isWarning ? AppTheme.duoOrange : AppTheme.duoGray;
    final Color textColor = isWarning ? AppTheme.duoOrangeDark : AppTheme.duoText;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bubbleBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: bubbleBorder.withValues(alpha: 0.2),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Custom painter that draws the original Polar Bear with scalable vector geometry
class _PolarBearPainter extends CustomPainter {
  final PolarBearMood mood;
  final double waveAngle;
  final double blinkVal;
  final double idleVal;
  final bool showPlatform;

  _PolarBearPainter({
    required this.mood,
    required this.waveAngle,
    required this.blinkVal,
    required this.idleVal,
    required this.showPlatform,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h * 0.52);

    final bool isWarning = mood == PolarBearMood.worried || mood == PolarBearMood.critical;
    final bool isCool = mood == PolarBearMood.happy || mood == PolarBearMood.celebrating;

    // 1. Warning Aura / Ambient Glow
    if (isWarning) {
      final Color auraColor = mood == PolarBearMood.critical
          ? AppTheme.duoRed.withValues(alpha: 0.18 + 0.1 * idleVal)
          : AppTheme.duoOrange.withValues(alpha: 0.15 + 0.08 * idleVal);
      final auraPaint = Paint()
        ..color = auraColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawCircle(center, w * 0.44, auraPaint);
    }

    // 2. Ice Floe Platform (Healthy ice vs melting puddle)
    if (showPlatform) {
      final platformRect = Rect.fromCenter(
        center: Offset(center.dx, h * 0.88),
        width: w * (isWarning ? 0.70 : 0.84),
        height: h * 0.16,
      );

      final Color iceFill = isWarning ? const Color(0xFFD6EEF8) : const Color(0xFFE2F4FD);
      final Color iceBorder = isWarning ? const Color(0xFFB5DBED) : const Color(0xFFBCE3F7);

      final platformPaint = Paint()
        ..color = iceFill
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = iceBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawOval(platformRect, platformPaint);
      canvas.drawOval(platformRect, borderPaint);

      // Ice highlights
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx - w * 0.15, h * 0.86),
          width: w * 0.35,
          height: h * 0.05,
        ),
        highlightPaint,
      );

      // Snowflakes / ice stars when cool
      if (isCool) {
        final starPaint = Paint()..color = const Color(0xFF5BC0EB);
        _drawSmallStar(canvas, Offset(w * 0.12, h * 0.35 + idleVal * 4), 5.0, starPaint);
        _drawSmallStar(canvas, Offset(w * 0.86, h * 0.28 - idleVal * 4), 6.5, starPaint);
        _drawSmallStar(canvas, Offset(w * 0.88, h * 0.65 + idleVal * 3), 4.5, starPaint);
      }
    }

    // Fur colors
    const Color furColor = Colors.white;
    final Color furShadow = isWarning ? const Color(0xFFFFECE5) : const Color(0xFFE9F4F9);
    final Color outlineColor = isWarning ? const Color(0xFF9E4822) : const Color(0xFF385566);
    const Color earInnerColor = Color(0xFFFFD6DD);
    const Color noseColor = Color(0xFF2A3B44);

    final linePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final furPaint = Paint()
      ..color = furColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = furShadow
      ..style = PaintingStyle.fill;

    // 3. Polar Bear Body (Rounded pear shape)
    final bodyCenter = Offset(center.dx, center.dy + h * 0.14);
    final bodyRect = Rect.fromCenter(
      center: bodyCenter,
      width: w * 0.54,
      height: h * 0.44,
    );

    // Body shadow
    canvas.drawOval(bodyRect, shadowPaint);
    canvas.drawOval(bodyRect, furPaint);
    canvas.drawOval(bodyRect, linePaint);

    // Belly soft highlight
    final bellyPaint = Paint()..color = isWarning ? const Color(0xFFFFF7F2) : const Color(0xFFF3FAFD);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bodyCenter.dx, bodyCenter.dy + h * 0.04),
        width: w * 0.36,
        height: h * 0.26,
      ),
      bellyPaint,
    );

    // 4. Polar Bear Ears (Round cute cartoon ears)
    final double earY = center.dy - h * 0.22;
    final double leftEarX = center.dx - w * 0.23;
    final double rightEarX = center.dx + w * 0.23;
    final double earRadius = w * 0.10;

    // Worried ear-droop angle
    final double earDroop = isWarning ? 3.0 : 0.0;

    void drawEar(double x, double y) {
      canvas.drawCircle(Offset(x, y + earDroop), earRadius, furPaint);
      canvas.drawCircle(Offset(x, y + earDroop), earRadius, linePaint);
      canvas.drawCircle(Offset(x, y + earDroop), earRadius * 0.60, Paint()..color = earInnerColor);
    }

    drawEar(leftEarX, earY);
    drawEar(rightEarX, earY);

    // 5. Polar Bear Head (Large rounded circle)
    final headCenter = Offset(center.dx, center.dy - h * 0.07);
    final headRect = Rect.fromCenter(
      center: headCenter,
      width: w * 0.58,
      height: h * 0.44,
    );

    canvas.drawOval(headRect, furPaint);
    canvas.drawOval(headRect, linePaint);

    // 6. Snout (Rounded ellipse)
    final snoutCenter = Offset(headCenter.dx, headCenter.dy + h * 0.07);
    final snoutRect = Rect.fromCenter(
      center: snoutCenter,
      width: w * 0.27,
      height: h * 0.17,
    );

    canvas.drawOval(
      snoutRect,
      Paint()..color = isWarning ? const Color(0xFFFFF2EB) : const Color(0xFFF0F8FC),
    );
    canvas.drawOval(snoutRect, linePaint);

    // Nose
    final noseCenter = Offset(snoutCenter.dx, snoutCenter.dy - h * 0.02);
    final noseRect = Rect.fromCenter(
      center: noseCenter,
      width: w * 0.11,
      height: h * 0.065,
    );
    final noseRRect = RRect.fromRectAndRadius(noseRect, const Radius.circular(8));
    canvas.drawRRect(noseRRect, Paint()..color = noseColor);

    // Nose highlight
    canvas.drawCircle(
      Offset(noseCenter.dx - w * 0.02, noseCenter.dy - h * 0.012),
      2.0,
      Paint()..color = Colors.white,
    );

    // 7. Mouth & Expression
    final mouthPaint = Paint()
      ..color = noseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    if (mood == PolarBearMood.happy || mood == PolarBearMood.celebrating) {
      // Big friendly smile
      mouthPath.moveTo(snoutCenter.dx - w * 0.06, snoutCenter.dy + h * 0.025);
      mouthPath.quadraticBezierTo(
        snoutCenter.dx,
        snoutCenter.dy + h * 0.065,
        snoutCenter.dx + w * 0.06,
        snoutCenter.dy + h * 0.025,
      );
      canvas.drawPath(mouthPath, mouthPaint);

      // Cute little tongue if celebrating
      if (mood == PolarBearMood.celebrating) {
        final tonguePaint = Paint()..color = const Color(0xFFFF6B81);
        final tonguePath = Path()
          ..moveTo(snoutCenter.dx - w * 0.03, snoutCenter.dy + h * 0.045)
          ..quadraticBezierTo(
            snoutCenter.dx,
            snoutCenter.dy + h * 0.075,
            snoutCenter.dx + w * 0.03,
            snoutCenter.dy + h * 0.045,
          );
        canvas.drawPath(tonguePath, tonguePaint);
      }
    } else if (mood == PolarBearMood.moderate) {
      // Thoughtful small smile/straight
      mouthPath.moveTo(snoutCenter.dx - w * 0.04, snoutCenter.dy + h * 0.035);
      mouthPath.quadraticBezierTo(
        snoutCenter.dx,
        snoutCenter.dy + h * 0.045,
        snoutCenter.dx + w * 0.04,
        snoutCenter.dy + h * 0.035,
      );
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      // Worried / sad inverted curve
      mouthPath.moveTo(snoutCenter.dx - w * 0.06, snoutCenter.dy + h * 0.055);
      mouthPath.quadraticBezierTo(
        snoutCenter.dx,
        snoutCenter.dy + h * 0.02,
        snoutCenter.dx + w * 0.06,
        snoutCenter.dy + h * 0.055,
      );
      canvas.drawPath(mouthPath, mouthPaint);
    }

    // 8. Eyes with Blinking
    final double leftEyeX = headCenter.dx - w * 0.12;
    final double rightEyeX = headCenter.dx + w * 0.12;
    final double eyeY = headCenter.dy - h * 0.02;
    final double eyeRadius = w * 0.045;

    void drawEye(double x, double y) {
      if (blinkVal > 0.6) {
        // Closed / blinking eye
        final closedEyePath = Path()
          ..moveTo(x - eyeRadius, y)
          ..quadraticBezierTo(x, y + eyeRadius * 0.8, x + eyeRadius, y);
        canvas.drawPath(closedEyePath, linePaint);
      } else if (isWarning) {
        // Worried / sad eyes (slight upward tilt with concerned pupil)
        canvas.drawCircle(Offset(x, y), eyeRadius * 0.85, Paint()..color = noseColor);
        canvas.drawCircle(Offset(x - 1, y - 1), eyeRadius * 0.35, Paint()..color = Colors.white);

        // Worried eyebrow
        final eyebrowPath = Path()
          ..moveTo(x - eyeRadius * 1.1, y - eyeRadius * 1.3)
          ..quadraticBezierTo(x, y - eyeRadius * 1.8, x + eyeRadius * 1.1, y - eyeRadius * 1.2);
        canvas.drawPath(eyebrowPath, linePaint);
      } else {
        // Bright, happy, sparkling cartoon eyes
        canvas.drawCircle(Offset(x, y), eyeRadius, Paint()..color = noseColor);
        canvas.drawCircle(Offset(x - 2, y - 2), eyeRadius * 0.45, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(x + 2, y + 2), eyeRadius * 0.20, Paint()..color = Colors.white);
      }
    }

    drawEye(leftEyeX, eyeY);
    drawEye(rightEyeX, eyeY);

    // 9. Cheeks (Cute rosy blush when happy/cool)
    if (isCool) {
      final blushPaint = Paint()..color = const Color(0xFFFFB3BA).withValues(alpha: 0.55);
      canvas.drawCircle(Offset(leftEyeX - w * 0.04, eyeY + h * 0.06), w * 0.04, blushPaint);
      canvas.drawCircle(Offset(rightEyeX + w * 0.04, eyeY + h * 0.06), w * 0.04, blushPaint);
    } else if (isWarning) {
      // Small sweat drop when worried
      final sweatPaint = Paint()..color = const Color(0xFF64B5F6);
      canvas.drawCircle(Offset(rightEyeX + w * 0.09, eyeY - h * 0.04), 3.0, sweatPaint);
    }

    // 10. Polar Bear Paws
    // Left Paw (Resting or waving)
    final leftPawCenter = Offset(center.dx - w * 0.24, bodyCenter.dy + h * 0.02);
    canvas.drawCircle(leftPawCenter, w * 0.08, furPaint);
    canvas.drawCircle(leftPawCenter, w * 0.08, linePaint);

    // Right Paw (Waving when happy, raised when celebrating)
    final double rightPawX = center.dx + w * 0.24 + (mood == PolarBearMood.celebrating ? 2.0 : 0.0);
    final double rightPawY = (mood == PolarBearMood.celebrating || mood == PolarBearMood.happy)
        ? (bodyCenter.dy - h * 0.08 + waveAngle * 10)
        : (bodyCenter.dy + h * 0.02);

    final rightPawCenter = Offset(rightPawX, rightPawY);
    canvas.drawCircle(rightPawCenter, w * 0.08, furPaint);
    canvas.drawCircle(rightPawCenter, w * 0.08, linePaint);

    // Paw pads (Cute little toe pads)
    final padPaint = Paint()..color = const Color(0xFF2A3B44);
    canvas.drawCircle(rightPawCenter, w * 0.035, padPaint);
    canvas.drawCircle(Offset(rightPawCenter.dx - 4, rightPawCenter.dy - 6), 2.0, padPaint);
    canvas.drawCircle(Offset(rightPawCenter.dx + 4, rightPawCenter.dy - 6), 2.0, padPaint);
    canvas.drawCircle(Offset(rightPawCenter.dx, rightPawCenter.dy - 8), 2.0, padPaint);
  }

  void _drawSmallStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final double angle = (i * math.pi / 2);
      final double nextAngle = angle + (math.pi / 4);
      final p1 = Offset(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius);
      final p2 = Offset(center.dx + math.cos(nextAngle) * (radius * 0.35), center.dy + math.sin(nextAngle) * (radius * 0.35));
      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.lineTo(p2.dx, p2.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PolarBearPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.waveAngle != waveAngle ||
        oldDelegate.blinkVal != blinkVal ||
        oldDelegate.idleVal != idleVal ||
        oldDelegate.showPlatform != showPlatform;
  }
}
