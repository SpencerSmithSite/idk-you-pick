import 'dart:ui';
import 'package:flutter/material.dart';

/// Modal overlay background using Liquid Glass principles.
///
/// Replaces solid black 60% scrims. Uses heavy blur + nearly transparent tint
/// so content behind stays readable but softened.
class LiquidGlassOverlay extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final double opacity;
  final VoidCallback? onDismiss;

  const LiquidGlassOverlay({
    super.key,
    required this.child,
    this.blurSigma = 35.0,
    this.opacity = 0.12,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onDismiss,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            color: isDark
                ? Colors.black.withValues(alpha: opacity)
                : Colors.white.withValues(alpha: opacity * 0.6),
            child: Center(
              child: GestureDetector(
                onTap: () {}, // prevent tap-through to background
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
