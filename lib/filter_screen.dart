import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_colors.dart';
import 'widgets/glass_card.dart';
import 'widgets/gradient_button.dart';

class FilterScreen extends StatefulWidget {
  final List<Map<String, dynamic>> restaurants;
  final Set<String> activeCuisines;
  final Set<String> activeTypes;
  final Set<String> activePriceTiers;
  final double maxDistance;
  final Future<void> Function() onSave;
  final ValueChanged<double>? onDistanceChanged;
  final bool useLocation;

  const FilterScreen({
    super.key,
    required this.restaurants,
    required this.activeCuisines,
    required this.activeTypes,
    required this.activePriceTiers,
    required this.maxDistance,
    required this.onSave,
    this.onDistanceChanged,
    this.useLocation = true,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late Set<String> _cuisines;
  late Set<String> _types;
  late Set<String> _priceTiers;
  late Set<String> _selectedCuisines;
  late Set<String> _selectedTypes;
  late Set<String> _selectedPriceTiers;
  late double _maxDistance;

  @override
  void initState() {
    super.initState();
    _cuisines = {
      ...widget.restaurants.map((r) => r['cuisine'] as String),
    };
    _types = {
      ...widget.restaurants.map((r) => r['type'] as String),
    };
    _priceTiers = {
      ...widget.restaurants.map((r) => r['priceTier'] as String),
    };
    _selectedCuisines = Set.from(widget.activeCuisines);
    _selectedTypes = Set.from(widget.activeTypes);
    _selectedPriceTiers = Set.from(widget.activePriceTiers);
    _maxDistance = widget.maxDistance;
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('filter_max_distance', _maxDistance);
    await prefs.setStringList('filter_cuisines', _selectedCuisines.toList());
    await prefs.setStringList('filter_types', _selectedTypes.toList());
    await prefs.setStringList('filter_prices', _selectedPriceTiers.toList());
  }

  Widget _buildChipGroup(String title, Set<String> all, Set<String> selected, void Function(String) toggle) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: all.map((value) {
            final isSelected = selected.contains(value);
            return FilterChip(
              label: Text(value),
              labelStyle: TextStyle(
                color: isSelected ? colors.chipTextDark : colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              selected: isSelected,
              selectedColor: colors.secondary,
              backgroundColor: colors.chipDefaultBg,
              checkmarkColor: colors.chipTextDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? colors.secondary
                      : colors.chipDefaultBorder,
                ),
              ),
              onSelected: (_) => setState(() {
                toggle(value);
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
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
            "Filters",
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
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _saveFilters();
              await widget.onSave();
              if (!mounted) return;
              navigator.pop();
            },
            child: Text(
              "Apply",
              style: TextStyle(
                color: colors.chipTextDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
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
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChipGroup("Cuisine", _cuisines, _selectedCuisines, (v) {
                if (_selectedCuisines.contains(v)) {
                  _selectedCuisines.remove(v);
                } else {
                  _selectedCuisines.add(v);
                }
              }),
              _buildChipGroup("Type", _types, _selectedTypes, (v) {
                if (_selectedTypes.contains(v)) {
                  _selectedTypes.remove(v);
                } else {
                  _selectedTypes.add(v);
                }
              }),
              _buildChipGroup("Price Tier", _priceTiers, _selectedPriceTiers, (v) {
                if (_selectedPriceTiers.contains(v)) {
                  _selectedPriceTiers.remove(v);
                } else {
                  _selectedPriceTiers.add(v);
                }
              }),
              if (widget.useLocation) ...[
                const SizedBox(height: 20),
                Text(
                  "Max Distance",
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _maxDistance,
                        min: 1.0,
                        max: 25.0,
                        divisions: 24,
                        label: '${_maxDistance.toStringAsFixed(0)} mi',
                        activeColor: colors.secondary,
                        inactiveColor: colors.chipDefaultBg,
                        onChanged: (value) {
                          setState(() {
                            _maxDistance = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      '${_maxDistance.toStringAsFixed(0)} mi',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 20),
                Text(
                  "Enable location to filter by distance",
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButton(
                    isSecondary: true,
                    label: 'Select All',
                    tooltip: 'Select all cuisines, types, and price tiers',
                    onPressed: () {
                      setState(() {
                        _selectedCuisines.addAll(_cuisines);
                        _selectedTypes.addAll(_types);
                        _selectedPriceTiers.addAll(_priceTiers);
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCuisines.clear();
                        _selectedTypes.clear();
                        _selectedPriceTiers.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.chipDefaultBg,
                      foregroundColor: colors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Clear All"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
