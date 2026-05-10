import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable glassmorphism card.
///
/// Uses a semi-transparent surface color + subtle border and shadow.
/// No BackdropFilter blur (performance-friendly fallback).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      margin: margin ?? const EdgeInsets.all(12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(color: colors.surfaceBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
