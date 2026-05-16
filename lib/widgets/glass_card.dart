import 'package:flutter/material.dart';
import 'liquid_glass.dart';

/// Deprecated — use [LiquidGlass] directly.
///
/// This class now delegates to [LiquidGlass] for backwards compatibility
/// and will be removed in a future release.
@Deprecated('Use LiquidGlass instead')
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
    return LiquidGlass(
      blurSigma: blurSigma ?? 20.0,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
