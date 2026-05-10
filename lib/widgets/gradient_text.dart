import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable gradient text widget using [ShaderMask].
///
/// The text is drawn in white and then masked with a linear gradient,
/// giving the appearance of gradient-colored text.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool isSecondary;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final gradient = isSecondary ? colors.secondaryGradient : colors.primaryGradient;

    final baseStyle = style ?? const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: baseStyle.copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}
