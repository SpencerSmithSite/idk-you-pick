import 'package:flutter/services.dart';

/// Centralized haptic feedback for the app.
///
/// Light = subtle UI feedback (chip tap, favorite toggle)
/// Medium = stronger affordance (winner reveal)
/// Selection = scrolling / stepping through options
class HapticsService {
  static void light() {
    HapticFeedback.lightImpact();
  }

  static void medium() {
    HapticFeedback.mediumImpact();
  }

  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void success() {
    HapticFeedback.mediumImpact();
  }
}
