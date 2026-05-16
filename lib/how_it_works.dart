import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'widgets/liquid_glass.dart';
import 'widgets/liquid_glass_button.dart';
import 'widgets/liquid_glass_overlay.dart';

/// First-run helper overlay shown before the user runs their first random choice.
/// Dismisses when user taps "Got it" or the background.
class HowItWorksOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const HowItWorksOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return LiquidGlassOverlay(
      blurSigma: 40,
      opacity: 0.12,
      onDismiss: onDismiss,
      child: LiquidGlass(
        blurSigma: 25,
        opacity: 0.18,
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How It Works',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _bullet(colors, Icons.tap_and_play, 'Tap Choose For Me to get a random pick instantly.'),
            const SizedBox(height: 8),
            _bullet(colors, Icons.compare_arrows, 'Tap Help Me Decide to compare two spots head-to-head.'),
            const SizedBox(height: 8),
            _bullet(colors, Icons.filter_alt, 'Use Filters to narrow by cuisine, type, price, or distance.'),
            const SizedBox(height: 8),
            _bullet(colors, Icons.settings, 'Visit Settings to add your own restaurants or change the theme.'),
            const SizedBox(height: 20),
            Center(
              child: LiquidGlassButton(
                label: 'Got it',
                onPressed: onDismiss,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(AppColors colors, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }
}
