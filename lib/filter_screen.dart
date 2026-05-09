import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterScreen extends StatefulWidget {
  final List<Map<String, dynamic>> restaurants;
  final Set<String> activeCuisines;
  final Set<String> activeTypes;
  final Set<String> activePriceTiers;
  final Future<void> Function() onSave;

  const FilterScreen({
    super.key,
    required this.restaurants,
    required this.activeCuisines,
    required this.activeTypes,
    required this.activePriceTiers,
    required this.onSave,
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
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('filter_cuisines', _selectedCuisines.toList());
    await prefs.setStringList('filter_types', _selectedTypes.toList());
    await prefs.setStringList('filter_prices', _selectedPriceTiers.toList());
  }

  Widget _buildChipGroup(String title, Set<String> all, Set<String> selected, void Function(String) toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
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
                color: isSelected ? const Color.fromARGB(255, 35, 38, 40) : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              selected: isSelected,
              selectedColor: const Color.fromARGB(255, 253, 139, 69),
              backgroundColor: const Color.fromARGB(255, 72, 80, 85),
              checkmarkColor: const Color.fromARGB(255, 35, 38, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? const Color.fromARGB(255, 253, 139, 69)
                      : Colors.white24,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Filters",
          style: TextStyle(
            color: Color.fromARGB(255, 62, 69, 74),
            fontWeight: FontWeight.bold,
            fontSize: 28,
            fontFamily: 'Arial',
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 47, 168, 156),
                Color(0xFF40E0D0),
              ],
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
            child: const Text(
              "Apply",
              style: TextStyle(
                color: Color.fromARGB(255, 35, 38, 40),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 72, 80, 85),
              Color.fromARGB(255, 35, 38, 40),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
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
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCuisines.addAll(_cuisines);
                        _selectedTypes.addAll(_types);
                        _selectedPriceTiers.addAll(_priceTiers);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 253, 139, 69),
                      foregroundColor: const Color.fromARGB(255, 35, 38, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Select All"),
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
                      backgroundColor: const Color.fromARGB(255, 72, 80, 85),
                      foregroundColor: Colors.white,
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
