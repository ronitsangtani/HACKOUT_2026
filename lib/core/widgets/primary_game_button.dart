import 'package:flutter/material.dart';
import '../../app/theme.dart';

enum GameButtonColor {
  green,
  blue,
  orange,
  yellow,
  white,
  gray,
  red,
}

/// Tactile 3D game button with signature Duolingo bottom-bevel press animation.
class PrimaryGameButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final GameButtonColor color;
  final IconData? icon;
  final bool isFullWidth;
  final double height;
  final double fontSize;
  final bool isLoading;

  const PrimaryGameButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = GameButtonColor.green,
    this.icon,
    this.isFullWidth = true,
    this.height = 54,
    this.fontSize = 16,
    this.isLoading = false,
  });

  @override
  State<PrimaryGameButton> createState() => _PrimaryGameButtonState();
}

class _PrimaryGameButtonState extends State<PrimaryGameButton> {
  bool _isPressed = false;

  (Color surface, Color bevel, Color text) _getColorConfig() {
    if (widget.onPressed == null) {
      return (AppTheme.duoGray, AppTheme.duoGrayDark, AppTheme.duoGrayDark);
    }
    switch (widget.color) {
      case GameButtonColor.green:
        return (AppTheme.duoGreen, AppTheme.duoGreenDark, Colors.white);
      case GameButtonColor.blue:
        return (AppTheme.duoBlue, AppTheme.duoBlueDark, Colors.white);
      case GameButtonColor.orange:
        return (AppTheme.duoOrange, AppTheme.duoOrangeDark, Colors.white);
      case GameButtonColor.yellow:
        return (AppTheme.duoYellow, AppTheme.duoYellowDark, AppTheme.duoText);
      case GameButtonColor.red:
        return (AppTheme.duoRed, AppTheme.duoRedDark, Colors.white);
      case GameButtonColor.white:
        return (Colors.white, AppTheme.duoGray, AppTheme.duoText);
      case GameButtonColor.gray:
        return (AppTheme.duoGrayLight, AppTheme.duoGray, AppTheme.duoText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (surfaceColor, bevelColor, textColor) = _getColorConfig();
    final double bevelHeight = widget.onPressed != null && !_isPressed ? 4.0 : 0.0;
    final double topMargin = _isPressed ? 4.0 : 0.0;

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: textColor,
            ),
          ),
          const SizedBox(width: 12),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, color: textColor, size: widget.fontSize + 4),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text.toUpperCase(),
          style: TextStyle(
            color: textColor,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: topMargin),
        height: widget.height - topMargin,
        width: widget.isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: widget.color == GameButtonColor.white
              ? Border.all(color: AppTheme.duoGray, width: 2)
              : null,
          boxShadow: [
            if (bevelHeight > 0)
              BoxShadow(
                color: bevelColor,
                offset: Offset(0, bevelHeight),
                blurRadius: 0,
              ),
          ],
        ),
        alignment: Alignment.center,
        child: buttonContent,
      ),
    );
  }
}
