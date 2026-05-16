import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'widgets/liquid_glass.dart';

/// Privacy Policy screen for App Store compliance.
///
/// Required because the app uses Geolocation services.
/// Displayed from Settings or onboarding.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    LiquidGlass(
                      blurSigma: 20,
                      opacity: 0.15,
                      padding: const EdgeInsets.all(20),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IDK You Pick — Privacy Policy',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Last updated: ${DateTime.now().year}',
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _section('1. Information We Collect', colors),
                            _paragraph(
                              'IDK You Pick does not collect, transmit, or store any personal information on external servers. '
                              'All data — including your restaurant preferences, favorites, history, and location settings — '
                              'is stored locally on your device using Apple\'s SharedPreferences framework (iOS) or Android\'s equivalent.',
                              colors,
                            ),
                            const SizedBox(height: 16),
                            _section('2. Location Data', colors),
                            _paragraph(
                              'When you enable location services, the app uses your current location solely to calculate distances '
                              'to nearby restaurants and filter results by proximity. Location data is:',
                              colors,
                            ),
                            const SizedBox(height: 8),
                            _bullet('Processed entirely on-device', colors),
                            _bullet('Never transmitted to servers', colors),
                            _bullet('Never stored after the app session ends', colors),
                            _bullet('Optional — you can disable location in Settings at any time', colors),
                            const SizedBox(height: 16),
                            _section('3. Third-Party Services', colors),
                            _paragraph(
                              'The app uses the following third-party packages, each governed by their own privacy policies:',
                              colors,
                            ),
                            const SizedBox(height: 8),
                            _bullet('Google Maps / Apple Maps — used only for opening navigation URLs', colors),
                            _bullet('DoorDash / UberEats — used only for opening partner URLs', colors),
                            _bullet('geolocator — open-source location reading library (on-device only)', colors),
                            _bullet('share_plus — system share sheet (no data collection)', colors),
                            const SizedBox(height: 16),
                            _section('4. Contact', colors),
                            _paragraph(
                              'If you have questions about this privacy policy, please open an issue on our GitHub repository.',
                              colors,
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Semantics(
                                button: true,
                                label: 'Close privacy policy',
                                child: TextButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.check, color: colors.primary),
                                  label: Text(
                                    'Got it',
                                    style: TextStyle(color: colors.primary),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, AppColors colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _paragraph(String text, AppColors colors) {
    return Text(text, style: TextStyle(color: colors.textSecondary));
  }

  Widget _bullet(String text, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: colors.primary)),
          Expanded(
            child: Text(text, style: TextStyle(color: colors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
