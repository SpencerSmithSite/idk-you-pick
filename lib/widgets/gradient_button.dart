import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable gradient pill button.
///
/// Wraps an [ElevatedButton] inside a [Container] with a gradient
/// background. The button itself is transparent so the gradient shows.
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final Widget? child;
  final bool isSecondary;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final IconData? icon;
  final String? tooltip;

  const GradientButton({
    super.key,
    this.onPressed,
    this.label,
    this.child,
    this.isSecondary = false,
    this.padding,
    this.fontSize,
    this.icon,
    this.tooltip,
  }) : assert(label != null || child != null, 'Provide label or child');

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final gradient = isSecondary ? colors.secondaryGradient : colors.primaryGradient;

    final buttonContent = child ?? (
      icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: (fontSize ?? 20) * 0.8),
                const SizedBox(width: 6),
                Text(label!),
              ],
            )
          : Text(label!)
    );

    final elevated = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        foregroundColor: colors.chipTextLight,
        textStyle: TextStyle(
          fontSize: fontSize ?? 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: buttonContent,
    );

    final container = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: elevated,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: container);
    }
    return container;
  }
}
