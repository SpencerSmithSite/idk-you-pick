import 'dart:ui';
import 'package:flutter/material.dart';

/// Core Liquid Glass widget — replaces GlassCard entirely.
///
/// Uses heavy BackdropFilter blur with very low opacity so content behind
/// remains readable but softened. Every instance gets a white edge highlight
/// (refraction) and a diffused shadow for depth.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tint;
  final List<BoxShadow>? shadows;
  final Border? border;

  const LiquidGlass({
    super.key,
    required this.child,
    this.blurSigma = 20.0,
    this.opacity = 0.15,
    this.borderRadius,
    this.padding,
    this.margin,
    this.tint,
    this.shadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(20);
    final baseTint = tint ?? (isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04));

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          margin: margin ?? const EdgeInsets.all(12),
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: baseTint.withValues(alpha: opacity),
            borderRadius: radius,
            border: border ?? Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: shadows ?? [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
