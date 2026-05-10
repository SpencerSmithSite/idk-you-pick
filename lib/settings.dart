import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_colors.dart';
import 'theme/theme_provider.dart';
import 'widgets/gradient_button.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, bool> restaurantPreferences;
  final Function(Map<String, bool>) onSave;
  final ThemeProvider themeProvider;

  const SettingsScreen({
    super.key,
    required this.restaurantPreferences,
    required this.onSave,
    required this.themeProvider,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Map<String, bool> _preferences;
  late List<String> _customRestaurants = []; // Initialize as an empty list
  final TextEditingController _restaurantController = TextEditingController();
  late ScrollController _scrollController; // Add a ScrollController

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // Initialize the ScrollController
    _preferences = Map.from(widget.restaurantPreferences);
    _loadCustomRestaurants();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the ScrollController
    super.dispose();
  }

  /// Load custom restaurants from SharedPreferences
  Future<void> _loadCustomRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final customRestaurants = prefs.getStringList('customRestaurants') ?? [];
    if (!mounted) return; // Ensure the widget is still mounted
    setState(() {
      _customRestaurants = customRestaurants;
      for (var restaurant in customRestaurants) {
        _preferences[restaurant] =
            true; // Add custom restaurants to preferences
      }
    });
  }

  /// Save custom restaurants to SharedPreferences
  Future<void> _saveCustomRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('customRestaurants', _customRestaurants);
  }

  /// Save all preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _preferences.entries) {
      await prefs.setBool(entry.key, entry.value);
    }
    await _saveCustomRestaurants(); // Save custom restaurants
    if (!mounted) return; // Check if the widget is still mounted
  }

  /// Add a new restaurant to the list
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

  /// Delete a custom-added restaurant
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
        title: Text(
          "Settings",
          style: TextStyle(
            color: colors.appBarText,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            fontFamily: 'Arial',
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
            onPressed: () async {
              await _savePreferences();
              if (!mounted) return;
              widget.onSave(_preferences);
              if (!mounted) return;
              final navigator = Navigator.of(context);
              if (!mounted) return;
              navigator.pop();
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
                return ListTile(
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
                );
              },
            ),
            const Divider(),
            Padding(
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
                  const SizedBox(height: 10), // Add spacing between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GradientButton(
                        isSecondary: true,
                        label: 'Select All',
                        onPressed: () {
                          setState(() {
                            // Select all restaurants
                            _preferences.updateAll((key, value) => true);
                          });
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ), // Add spacing between the buttons
                      GradientButton(
                        isSecondary: true,
                        label: 'Deselect All',
                        onPressed: () {
                          setState(() {
                            // Deselect all restaurants
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
                controller: _scrollController, // Attach the ScrollController
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(10),
                // Removed thumbColor as it is not a valid parameter
                child: ListView(
                  controller: _scrollController, // Attach the ScrollController
                  padding: const EdgeInsets.all(20),
                  children:
                      _preferences.keys.map((restaurant) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              checkboxTheme: CheckboxThemeData(
                                side: BorderSide(
                                  color: colors.chipDefaultBorder,
                                  width: 2, // Thickness of the outline
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    5,
                                  ), // Rounded corners
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
                              ), // Slight primary background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              secondary:
                                  _customRestaurants.contains(restaurant)
                                      ? IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: colors.danger,
                                        ),
                                        onPressed:
                                            () =>
                                                _deleteRestaurant(restaurant),
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
