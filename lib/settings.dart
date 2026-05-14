import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'demo_service.dart';
import 'onboarding.dart';
import 'privacy_policy.dart';
import 'theme/app_colors.dart';
import 'theme/theme_provider.dart';
import 'widgets/gradient_button.dart';
import 'widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, bool> restaurantPreferences;
  final Function(Map<String, bool>) onSave;
  final ThemeProvider themeProvider;
  final ValueChanged<bool>? onLocationChanged;
  final bool useLocation;

  const SettingsScreen({
    super.key,
    required this.restaurantPreferences,
    required this.onSave,
    required this.themeProvider,
    this.onLocationChanged,
    this.useLocation = true,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Map<String, bool> _preferences;
  late List<String> _customRestaurants = [];
  late bool _useLocation;
  final TextEditingController _restaurantController = TextEditingController();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _preferences = Map.from(widget.restaurantPreferences);
    _useLocation = widget.useLocation;
    _loadCustomRestaurants();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final customRestaurants = prefs.getStringList('customRestaurants') ?? [];
    if (!mounted) return;
    setState(() {
      _customRestaurants = customRestaurants;
      for (var restaurant in customRestaurants) {
        _preferences[restaurant] = true;
      }
    });
  }

  Future<void> _saveCustomRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('customRestaurants', _customRestaurants);
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _preferences.entries) {
      await prefs.setBool(entry.key, entry.value);
    }
    await _saveCustomRestaurants();
    if (!mounted) return;
  }

  Future<void> _toggleLocation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_location', value);
    setState(() {
      _useLocation = value;
    });
    widget.onLocationChanged?.call(value);
  }

  void _addRestaurant() {
    final newRestaurant = _restaurantController.text.trim();
    if (newRestaurant.isNotEmpty && !_preferences.containsKey(newRestaurant)) {
      setState(() {
        _preferences[newRestaurant] = true;
        _customRestaurants.add(newRestaurant);
        _restaurantController.clear();
      });
      _savePreferences();
    }
  }

  void _deleteRestaurant(String restaurant) {
    setState(() {
      _preferences.remove(restaurant);
      _customRestaurants.remove(restaurant);
    });
    _savePreferences();
  }

  Widget _buildThemeChip(String label, ThemeMode value, ThemeMode current, AppColors colors) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) async {
        await widget.themeProvider.setThemeMode(value);
      },
      selectedColor: colors.secondary,
      backgroundColor: colors.chipDefaultBg,
      labelStyle: TextStyle(
        color: isSelected ? colors.chipTextDark : colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? colors.secondary : colors.chipDefaultBorder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Settings",
            style: TextStyle(
              color: colors.appBarText,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Arial',
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors.appBarGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save settings',
            onPressed: () async {
              await _savePreferences();
              if (!mounted) return;
              widget.onSave(_preferences);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            ListenableBuilder(
              listenable: widget.themeProvider,
              builder: (context, child) {
                final mode = widget.themeProvider.themeMode;
                return GlassCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    leading: Icon(Icons.palette, color: colors.textSecondary),
                    title: Text(
                      'Appearance',
                      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildThemeChip('System', ThemeMode.system, mode, colors),
                        const SizedBox(width: 8),
                        _buildThemeChip('Light', ThemeMode.light, mode, colors),
                        const SizedBox(width: 8),
                        _buildThemeChip('Dark', ThemeMode.dark, mode, colors),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                leading: Icon(Icons.tour, color: colors.textSecondary),
                title: Text('Restart Onboarding', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                trailing: TextButton(
                  onPressed: () async {
                    await OnboardingService.resetOnboarding();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Onboarding will restart on next launch.')),
                    );
                  },
                  child: Text('Reset', style: TextStyle(color: colors.secondary)),
                ),
              ),
            ),
            const Divider(),
            GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(16),
              child: DemoModeTile(colors: colors),
            ),
            const Divider(),
            GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                leading: Icon(Icons.location_on, color: colors.textSecondary),
                title: Text('Use My Location', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text(
                  _useLocation
                      ? 'Show nearby restaurants based on your location'
                      : 'Location is off. All restaurants will be shown.',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                trailing: Switch(
                  value: _useLocation,
                  activeTrackColor: colors.secondary,
                  thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return colors.foregroundOnDark;
                    }
                    return colors.switchThumbUnselected;
                  }),
                  onChanged: _toggleLocation,
                ),
              ),
            ),
            const Divider(),
            GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                leading: Icon(Icons.privacy_tip, color: colors.textSecondary),
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: colors.textMuted, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                  );
                },
              ),
            ),
            const Divider(),
            GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(16),
              child: const AboutTile(),
            ),
            const Divider(),
            GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _restaurantController,
                          decoration: InputDecoration(
                            hintText: "Add a new restaurant",
                            hintStyle: TextStyle(color: colors.textMuted),
                            filled: true,
                            fillColor: colors.primary,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: colors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GradientButton(
                        isSecondary: true,
                        label: 'Add',
                        onPressed: _addRestaurant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GradientButton(
                        isSecondary: true,
                        label: 'Select All',
                        onPressed: () {
                          setState(() {
                            _preferences.updateAll((key, value) => true);
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      GradientButton(
                        isSecondary: true,
                        label: 'Deselect All',
                        onPressed: () {
                          setState(() {
                            _preferences.updateAll((key, value) => false);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(10),
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  children: _preferences.keys.map((restaurant) {
                    return GlassCard(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(16),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            side: BorderSide(
                              color: colors.chipDefaultBorder,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            restaurant,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          value: _preferences[restaurant],
                          activeColor: colors.secondary,
                          checkColor: colors.chipTextDark,
                          onChanged: (bool? value) {
                            setState(() {
                              _preferences[restaurant] = value ?? false;
                            });
                          },
                          tileColor: colors.primary.withValues(
                            alpha: 0.04,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          secondary: _customRestaurants.contains(restaurant)
                              ? IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: colors.danger,
                                  ),
                                  tooltip: 'Delete restaurant',
                                  onPressed: () => _deleteRestaurant(restaurant),
                                )
                              : null,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggles demo-mode (fake restaurant data) in settings.
class DemoModeTile extends StatefulWidget {
  final AppColors colors;

  const DemoModeTile({super.key, required this.colors});

  @override
  State<DemoModeTile> createState() => _DemoModeTileState();
}

class _DemoModeTileState extends State<DemoModeTile> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await DemoService.isEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = v;
    });
  }

  Future<void> _toggle(bool value) async {
    await DemoService.setEnabled(value);
    setState(() {
      _enabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.videogame_asset, color: widget.colors.textSecondary),
      title: Text(
        'Demo Mode',
        style: TextStyle(color: widget.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text(
        'Use fake restaurants for screenshots and testing',
        style: TextStyle(color: widget.colors.textSecondary, fontSize: 12),
      ),
      trailing: Switch(
        value: _enabled,
        activeTrackColor: widget.colors.secondary,
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white70;
        }),
        onChanged: _toggle,
      ),
    );
  }
}

/// About tile displaying version, build number, and tap-to-copy support info.
class AboutTile extends StatefulWidget {
  const AboutTile({super.key});

  @override
  State<AboutTile> createState() => _AboutTileState();
}

class _AboutTileState extends State<AboutTile> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _info = info);
  }

  void _copySupportInfo(BuildContext context, AppColors colors) {
    final info = _info;
    if (info == null) return;
    final text = 'IDK You Pick\nVersion: ${info.version}\nBuild: ${info.buildNumber}\nPackage: ${info.packageName}';
    FlutterClipboard.copy(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Support info copied to clipboard', style: TextStyle(color: colors.chipTextDark)),
        backgroundColor: colors.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final info = _info;

    return ListTile(
      leading: Icon(Icons.info_outline, color: colors.textSecondary),
      title: Text(
        'About',
        style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: info == null
          ? Text('Loading...', style: TextStyle(color: colors.textSecondary, fontSize: 12))
          : Text(
              'v${info.version} (${info.buildNumber})',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
      trailing: IconButton(
        icon: Icon(Icons.content_copy, color: colors.textMuted, size: 20),
        tooltip: 'Copy support info',
        onPressed: () => _copySupportInfo(context, colors),
      ),
      onTap: () => _copySupportInfo(context, colors),
    );
  }
}
