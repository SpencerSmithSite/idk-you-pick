import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A solid gradient button that complements the Liquid Glass aesthetic.
///
/// Uses the app’s primary or secondary gradient and animates on press.
class GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final bool isSecondary;
  final double borderRadius;

  const GradientButton({
    super.key,
    this.onPressed,
    required this.label,
    this.padding,
    this.fontSize,
    this.isSecondary = false,
    this.borderRadius = 20.0,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
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
    final colors = AppColors.of(context);
    final gradient = widget.isSecondary ? colors.secondaryGradient : colors.primaryGradient;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final scale = 1.0 - (_controller.value * 0.02);
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize ?? 20,
                  fontWeight: FontWeight.w600,
                  color: colors.chipTextDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
