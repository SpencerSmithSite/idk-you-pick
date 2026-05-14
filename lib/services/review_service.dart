import 'package:shared_preferences/shared_preferences.dart';

/// Tracks when to show the App Store review prompt.
///
/// Rules:
/// - Show after 3+ successful "Choose For Me" picks
/// - Max once every 30 days
/// - Only if the user hasn't already rated (we track locally)
class ReviewService {
  static const String _pickCountKey = 'review_pick_count';
  static const String _lastPromptedKey = 'review_last_prompted_ms';
  static const String _hasRatedKey = 'review_has_rated';
  static const int _minPicks = 3;
  static const Duration _minInterval = Duration(days: 30);

  /// Call this every time the user completes a "Choose For Me" pick
  /// (random choice or head-to-head winner).
  static Future<void> recordSuccessfulPick() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_pickCountKey) ?? 0;
    await prefs.setInt(_pickCountKey, current + 1);
  }

  /// Whether the review prompt should be shown now.
  static Future<bool> shouldPrompt() async {
    final prefs = await SharedPreferences.getInstance();

    // Already rated — never prompt again.
    if (prefs.getBool(_hasRatedKey) ?? false) return false;

    // Need minimum picks.
    final pickCount = prefs.getInt(_pickCountKey) ?? 0;
    if (pickCount < _minPicks) return false;

    // Respect the 30-day cooldown.
    final lastPrompted = prefs.getInt(_lastPromptedKey);
    if (lastPrompted != null) {
      final elapsed = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastPrompted));
      if (elapsed < _minInterval) return false;
    }

    return true;
  }

  /// Marks that we showed the prompt (regardless of whether the user
  /// actually rated — the OS handles that). Also resets pick count so
  /// we don't immediately re-trigger if they keep using the app.
  static Future<void> markPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_lastPromptedKey, now);
    await prefs.setInt(_pickCountKey, 0);
  }

  /// Marks that the user has rated the app (e.g. via a manual
  /// "Rate us" button). Future sessions will not prompt.
  static Future<void> markRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
  }

  /// Exposed for testing / resetting state.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pickCountKey);
    await prefs.remove(_lastPromptedKey);
    await prefs.remove(_hasRatedKey);
  }

  /// Current pick count (diagnostic).
  static Future<int> pickCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pickCountKey) ?? 0;
  }
}
