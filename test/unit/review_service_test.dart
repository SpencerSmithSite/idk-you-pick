import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_chooser/services/review_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ReviewService.reset();
  });

  tearDown(() async {
    await ReviewService.reset();
  });

  group('ReviewService', () {
    test('pickCount starts at 0', () async {
      expect(await ReviewService.pickCount(), 0);
    });

    test('recordSuccessfulPick increments count', () async {
      await ReviewService.recordSuccessfulPick();
      await ReviewService.recordSuccessfulPick();
      expect(await ReviewService.pickCount(), 2);
    });

    test('should not prompt before 3 picks', () async {
      await ReviewService.recordSuccessfulPick();
      await ReviewService.recordSuccessfulPick();
      expect(await ReviewService.shouldPrompt(), false);
    });

    test('should prompt after 3 picks with no prior prompt', () async {
      await ReviewService.recordSuccessfulPick();
      await ReviewService.recordSuccessfulPick();
      await ReviewService.recordSuccessfulPick();
      expect(await ReviewService.shouldPrompt(), true);
    });

    test('markPrompted resets pick count and blocks for 30 days', () async {
      await ReviewService.recordSuccessfulPick();
      await ReviewService.recordSuccessfulPick();
      await ReviewService.recordSuccessfulPick();
      expect(await ReviewService.shouldPrompt(), true);

      await ReviewService.markPrompted();
      expect(await ReviewService.pickCount(), 0);
      expect(await ReviewService.shouldPrompt(), false);
    });

    test('markRated permanently blocks prompts', () async {
      await ReviewService.recordSuccessfulPick();
      await ReviewService.recordSuccessfulPick();
      await ReviewService.recordSuccessfulPick();
      await ReviewService.markRated();
      expect(await ReviewService.shouldPrompt(), false);
    });

    test('reset clears all state', () async {
      await ReviewService.recordSuccessfulPick();
      await ReviewService.recordSuccessfulPick();
      await ReviewService.recordSuccessfulPick();
      await ReviewService.markPrompted();
      await ReviewService.reset();
      expect(await ReviewService.pickCount(), 0);
      expect(await ReviewService.shouldPrompt(), false);
    });
  });
}
