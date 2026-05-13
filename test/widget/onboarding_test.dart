import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_chooser/onboarding.dart';

/// Widget tests for the onboarding flow.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('onboarding shows first slide with title and icon',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onComplete: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to IDK!'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });

  testWidgets('first slide shows Next button and Skip link',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onComplete: () {}),
      ),
    );
    await tester.pumpAndSettle();

    // Button says "Next" on non-final slides
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('tapping Next advances through all slides', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onComplete: () {}),
      ),
    );
    await tester.pumpAndSettle();

    // Slide 1
    expect(find.text('Welcome to IDK!'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Slide 2
    expect(find.text('Random Pick'), findsOneWidget);
    expect(find.byIcon(Icons.shuffle), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Slide 3
    expect(find.text('Help Me Decide'), findsOneWidget);
    expect(find.byIcon(Icons.compare_arrows), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Slide 4 (final)
    expect(find.text('Make It Yours'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    // Final slide button says "Get Started" — no Skip
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });

  testWidgets('tapping Get Started on final slide triggers onComplete',
      (tester) async {
    bool completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          onComplete: () => completed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Advance through all 4 slides
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    // Now on final slide
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  testWidgets('tapping Skip triggers onComplete immediately', (tester) async {
    bool completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          onComplete: () => completed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  testWidgets('dot indicators reflect current page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onComplete: () {}),
      ),
    );
    await tester.pumpAndSettle();

    final dots = find.byType(AnimatedContainer);
    // Should have at least 4 dot indicators
    expect(dots, findsAtLeastNWidgets(4));

    // First dot should be wider (active) — check width via constraints
    final firstDot = tester.widgetList(dots).first as AnimatedContainer;
    final constraints = firstDot.constraints;
    expect(constraints, isNotNull);
    final widthConstraint = constraints as BoxConstraints;
    expect(widthConstraint.minWidth, greaterThan(8));
  });
}
