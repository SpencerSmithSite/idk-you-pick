import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'widgets/glass_card.dart';
import 'widgets/gradient_button.dart';
import 'widgets/liquid_glass_app_bar.dart';
import 'services/haptics_service.dart';

class PriceBracketScreen extends StatefulWidget {
  const PriceBracketScreen({super.key});

  @override
  State<PriceBracketScreen> createState() => _PriceBracketScreenState();
}

class _PriceBracketScreenState extends State<PriceBracketScreen> {
  String? _selectedTier;

  static const List<String> _tiers = ['\$', '\$\$', '\$\$\$'];

  void _onTierTap(String tier) {
    HapticsService.light();
    setState(() {
      _selectedTier = tier;
    });
  }

  void _startBattle() {
    if (_selectedTier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Select a price tier first',
            style: TextStyle(color: AppColors.of(context).chipTextDark),
          ),
          backgroundColor: AppColors.of(context).secondary,
        ),
      );
      return;
    }
    HapticsService.medium();
    Navigator.pop(context, _selectedTier);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: LiquidGlassAppBar(
        title: const Text('Price Bracket Battle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pick a price tier',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll battle restaurants in that bracket.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _tiers.map((tier) {
                      final isSelected = _selectedTier == tier;
                      return ChoiceChip(
                        label: Text(tier),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? colors.chipTextDark
                              : colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        selected: isSelected,
                        selectedColor: colors.secondary,
                        backgroundColor: colors.chipDefaultBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? colors.secondary
                                : colors.chipDefaultBorder,
                          ),
                        ),
                        onSelected: (_) => _onTierTap(tier),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: 'Start Battle',
                    onPressed: _startBattle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
