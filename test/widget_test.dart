// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:rest_chooser/main.dart';
import 'package:rest_chooser/theme/theme_provider.dart';

void main() {
  testWidgets('App loads default screen', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    await tester.pumpWidget(MyApp(themeProvider: themeProvider));

    // Verify we see the default welcome text and buttons.
    expect(find.text('Not sure where to eat?'), findsOneWidget);
    expect(find.text('Choose For Me'), findsOneWidget);
    expect(find.text('Help Me Decide'), findsOneWidget);
  });
}
