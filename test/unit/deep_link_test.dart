import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rest_chooser/share_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.llfbandit.app_links/messages');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getInitialLink') return null;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Deep Link Tests', () {
    test('ShareService.getInitialLink returns Future<Uri?>', () async {
      final result = await ShareService.getInitialLink();
      expect(result, isNull);
    });

    test('idkyoupick://restaurant/taco-bell produces expected slug', () {
      final uri = Uri.parse('idkyoupick://restaurant/taco-bell');
      expect(uri.scheme, equals('idkyoupick'));
      expect(uri.host, equals('restaurant'));
      expect(uri.pathSegments.isNotEmpty, isTrue);
      expect(uri.pathSegments[0], equals('taco-bell'));
    });

    test('idkyoupick://invite splits cuisines query param correctly', () {
      final uri = Uri.parse('idkyoupick://invite?cuisines=Mexican,Italian');
      expect(uri.scheme, equals('idkyoupick'));
      expect(uri.host, equals('invite'));
      expect(uri.queryParameters['cuisines'], equals('Mexican,Italian'));
      final cuisines = uri.queryParameters['cuisines']?.split(',') ?? [];
      expect(cuisines, equals(['Mexican', 'Italian']));
    });

    test('unknown scheme returns non-idkyoupick and should be ignored', () {
      final uri = Uri.parse('https://restaurant/taco-bell');
      expect(uri.scheme, isNot(equals('idkyoupick')));
    });
  });
}
