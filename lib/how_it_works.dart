import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'widgets/gradient_button.dart';

/// First-run helper overlay shown before the user runs their first random choice.
/// Dismisses when user taps "Got it".
class HowItWorksOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const HowItWorksOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // prevent tap-through to background
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.primary, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How It Works',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
                    child: GradientButton(
                      label: 'Got it',
                      onPressed: onDismiss,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
