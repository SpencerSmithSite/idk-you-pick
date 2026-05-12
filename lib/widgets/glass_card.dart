import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable glassmorphism card.
///
/// Uses BackdropFilter blur + a semi-transparent surface color for a frosted
/// glass effect. This is a replacement for the old `GlassCard` that relied
/// solely on opacity. Now it actually blurs whatever sits behind it.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? blurSigma;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final sigma = blurSigma ?? colors.backdropBlur;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
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
        ),
      ),
    );
  }
}
