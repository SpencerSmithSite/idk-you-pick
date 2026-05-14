import 'package:flutter_test/flutter_test.dart';
import 'package:rest_chooser/services/haptics_service.dart';

void main() {
  group('HapticsService', () {
    testWidgets('light does not throw', (tester) async {
      expect(() => HapticsService.light(), returnsNormally);
    });
    testWidgets('medium does not throw', (tester) async {
      expect(() => HapticsService.medium(), returnsNormally);
    });
    testWidgets('heavy does not throw', (tester) async {
      expect(() => HapticsService.heavy(), returnsNormally);
    });
    testWidgets('selection does not throw', (tester) async {
      expect(() => HapticsService.selection(), returnsNormally);
    });
    testWidgets('success does not throw', (tester) async {
      expect(() => HapticsService.success(), returnsNormally);
    });
  });
}
