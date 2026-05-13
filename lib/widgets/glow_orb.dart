import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable radial glow orb for ambient background decoration.
///
/// Place inside a [Stack] behind content, wrapped with [IgnorePointer]
/// so it does not intercept gestures.
class GlowOrb extends StatelessWidget {
  final double size;
  final Alignment alignment;
  final List<Color>? colors;

  const GlowOrb({
    super.key,
    this.size = 300,
    this.alignment = Alignment.topLeft,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final gradientColors = colors ?? [appColors.glowTint, Colors.transparent];

    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: gradientColors,
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
