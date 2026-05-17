import 'package:flutter_test/flutter_test.dart';
import 'package:rest_chooser/share_service.dart';

void main() {
  group('ShareService.generateSlug', () {
    test('converts normal name to kebab-case', () {
      expect(ShareService.generateSlug('Taco Bell'), 'taco-bell');
      expect(ShareService.generateSlug('Pizza   Hut'), 'pizza-hut');
      expect(ShareService.generateSlug('  Chipotle  '), 'chipotle');
    });

    test('handles mixed case', () {
      expect(ShareService.generateSlug('McDonalds'), 'mcdonalds');
      expect(ShareService.generateSlug('Five Guys'), 'five-guys');
    });

    test('strips special characters', () {
      expect(ShareService.generateSlug("Joe's Diner"), 'joes-diner');
      expect(ShareService.generateSlug('Café & Bistro!'), 'caf-bistro');
      expect(ShareService.generateSlug('P.F. Chang\'s'), 'pf-changs');
    });

    test('collapses multiple hyphens', () {
      expect(ShareService.generateSlug('A  B  C'), 'a-b-c');
    });

    test('empty or all-special-chars name falls back to "restaurant"', () {
      expect(ShareService.generateSlug(''), 'restaurant');
      expect(ShareService.generateSlug('!@#\$%'), 'restaurant');
    });

    test('handles duplicate slugs with existingSlugs set', () {
      final existing = {'taco-bell'};
      expect(
        ShareService.generateSlug('Taco Bell', existingSlugs: existing),
        'taco-bell-2',
      );
    });

    test('increments duplicate suffix correctly', () {
      final existing = {'taco-bell', 'taco-bell-2', 'taco-bell-3'};
      expect(
        ShareService.generateSlug('Taco Bell', existingSlugs: existing),
        'taco-bell-4',
      );
    });

    test('no duplicate suffix when slug is unique', () {
      final existing = {'pizza-hut', 'chipotle'};
      expect(
        ShareService.generateSlug('Taco Bell', existingSlugs: existing),
        'taco-bell',
      );
    });

    test('numeric names are preserved', () {
      expect(ShareService.generateSlug('123 Main'), '123-main');
      expect(ShareService.generateSlug('Restaurant 99'), 'restaurant-99');
    });

    test('leading/trailing hyphens are stripped', () {
      expect(ShareService.generateSlug('-Test-'), 'test');
      expect(ShareService.generateSlug('---hello---world---'), 'hello-world');
    });
  });
}
