import 'package:in_app_review/in_app_review.dart';
import 'review_service.dart';

/// Encapsulates the review prompt logic using the `in_app_review` package.
class ReviewPrompt {
  static final InAppReview _inAppReview = InAppReview.instance;

  /// Call after a successful "Choose For Me" or head-to-head winner.
  static Future<void> maybeShow() async {
    await ReviewService.recordSuccessfulPick();

    final should = await ReviewService.shouldPrompt();
    if (!should) return;

    final available = await _inAppReview.isAvailable();
    if (!available) return;

    await _inAppReview.requestReview();
    await ReviewService.markPrompted();
  }

  /// Opens the App Store listing directly (for a manual "Rate us" button).
  static Future<void> openStoreListing() async {
    final available = await _inAppReview.isAvailable();
    if (available) {
      // On iOS this opens the app's review page in the App Store.
      await _inAppReview.openStoreListing();
    }
  }
}
