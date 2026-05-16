import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_colors.dart';
import 'widgets/gradient_button.dart';
import 'widgets/glow_orb.dart';

/// Onboarding screen walkthrough (4 slides).
/// Shown on first app launch.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    {
      'icon': Icons.restaurant_menu,
      'title': 'Welcome to IDK!',
      'body': 'Tired of the "where should we eat?" debate? Let us decide for you.',
    },
    {
      'icon': Icons.shuffle,
      'title': 'Random Pick',
      'body': 'Tap "Randomize" and we\'ll pick one restaurant from your list instantly.',
    },
    {
      'icon': Icons.compare_arrows,
      'title': 'Help Me Decide',
      'body': 'Pit two restaurants head-to-head and keep choosing until you crown a winner.',
    },
    {
      'icon': Icons.settings,
      'title': 'Make It Yours',
      'body': 'Filter by cuisine, type, price, distance, and save your preferences.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // consistent gradient background for text contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors.backgroundGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // subtle background orbs
          const GlowOrb(size: 300),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _slides.length,
                    itemBuilder: (ctx, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              slide['icon'] as IconData,
                              size: 80,
                              color: colors.primary,
                            ),
                            const SizedBox(height: 32),
                            Text(
                              slide['title'] as String,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slide['body'] as String,
                              style: TextStyle(
                                color: colors.textSecondarySolid,
                                fontSize: 16,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // dot indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final active = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? colors.primary : colors.chipDefaultBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: GradientButton(
                    label: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    onPressed: _next,
                  ),
                ),
                if (_currentPage < _slides.length - 1)
                  TextButton(
                    onPressed: widget.onComplete,
                    child: Text(
                      'Skip',
                      style: TextStyle(color: colors.textMuted, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Service that tracks whether the user has completed onboarding.
class OnboardingService {
  static const _key = 'onboarding_complete';

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Reset onboarding flag so the walkthrough shows again on next launch.
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
  }
}
