import 'package:flutter/material.dart';
import 'liquid_glass.dart';

/// A tappable button wrapped in LiquidGlass that animates on press.
///
/// Default: opacity 0.15, blur 20.
/// Pressed: opacity 0.28, blur 30, scale 0.98.
class LiquidGlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? label;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final IconData? icon;
  final String? tooltip;
  final double blurSigma;
  final double opacity;

  const LiquidGlassButton({
    super.key,
    this.onPressed,
    this.label,
    this.child,
    this.padding,
    this.fontSize,
    this.icon,
    this.tooltip,
    this.blurSigma = 20.0,
    this.opacity = 0.15,
  }) : assert(label != null || child != null, 'Provide label or child');

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final buttonContent = widget.child ?? (
        widget.icon != null
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: (widget.fontSize ?? 20) * 0.8),
            const SizedBox(width: 6),
            Text(widget.label!),
          ],
        )
            : Text(widget.label!)
    );

    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final opacity = 0.15 + (_controller.value * 0.13);
          final blur = 20.0 + (_controller.value * 10.0);
          final scale = 1.0 - (_controller.value * 0.02);
          return Transform.scale(
            scale: scale,
            child: LiquidGlass(
              blurSigma: blur,
              opacity: opacity,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              borderRadius: BorderRadius.circular(20),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: widget.fontSize ?? 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                child: buttonContent,
              ),
            ),
          );
        },
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
