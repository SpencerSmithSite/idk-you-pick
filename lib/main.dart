import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'settings.dart'; // Add this import
import 'filter_screen.dart'; // Filter UI

void main() {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  } catch (e) {
    rethrow;
  }
}

/// The root widget of your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return MaterialApp(
        title: 'IDK, What do you want?',
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// The stateful widget for your app's main screen.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _restaurants = [];
  List<Map<String, dynamic>> _restaurantDetails = [];
  Map<String, bool> _restaurantPreferences = {};
  String? _chosenRestaurant;
  String? _optionA;
  String? _optionB;
  String? _errorMessage;

  // Filter state
  Set<String> _activeCuisines = {};
  Set<String> _activeTypes = {};
  Set<String> _activePriceTiers = {};

  // Flags to manage app modes
  bool _helpMeDecideMode = false;
  bool _randomChoiceMode = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _loadRestaurants();
      await _loadFilters();
      setState(() {
        _restaurantPreferences = {
          for (var item in _restaurants) item: prefs.getBool(item) ?? true,
        };
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Initialization failed.";
      });
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/restaurants.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        // Support both old format (List<String>) and new rich format (List<Map>)
        if (jsonList.isNotEmpty && jsonList.first is Map) {
          _restaurantDetails = jsonList.cast<Map<String, dynamic>>();
          _restaurants = _restaurantDetails
              .map((r) => r['name'] as String)
              .toList();
        } else {
          _restaurants = jsonList.cast<String>();
          _restaurantDetails = [];
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load restaurants.";
      });
    }
  }

  Map<String, dynamic>? _getRestaurantDetails(String name) {
    if (_restaurantDetails.isEmpty) return null;
    try {
      return _restaurantDetails.firstWhere((r) => r['name'] == name);
    } catch (e) {
      return null;
    }
  }

  /// Load saved filter state from SharedPreferences.
  Future<void> _loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _activeCuisines = (prefs.getStringList('filter_cuisines') ?? []).toSet();
      _activeTypes = (prefs.getStringList('filter_types') ?? []).toSet();
      _activePriceTiers = (prefs.getStringList('filter_prices') ?? []).toSet();
    });
  }

  /// Returns the pool of restaurants after applying preferences and active filters.
  List<String> get _filteredPool {
    if (_restaurantDetails.isEmpty) {
      return _restaurants.where((r) => _restaurantPreferences[r] ?? true).toList();
    }
    return _restaurantDetails.where((r) {
      final name = r['name'] as String;
      if (!(_restaurantPreferences[name] ?? true)) return false;
      if (_activeCuisines.isNotEmpty && !_activeCuisines.contains(r['cuisine'])) return false;
      if (_activeTypes.isNotEmpty && !_activeTypes.contains(r['type'])) return false;
      if (_activePriceTiers.isNotEmpty && !_activePriceTiers.contains(r['priceTier'])) return false;
      return true;
    }).map((r) => r['name'] as String).toList();
  }

  Widget _buildRestaurantDetailChip(String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRestaurantMeta(Map<String, dynamic>? details) {
    if (details == null || details.isEmpty) return const SizedBox.shrink();
    final cuisine = details['cuisine'] as String?;
    final type = details['type'] as String?;
    final priceTier = details['priceTier'] as String?;
    final tags = (details['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[];

    return Column(
      children: [
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            if (cuisine != null && cuisine.isNotEmpty)
              _buildRestaurantDetailChip(cuisine, const Color.fromARGB(255, 72, 80, 85)),
            if (type != null && type.isNotEmpty)
              _buildRestaurantDetailChip(type, const Color.fromARGB(255, 47, 168, 156)),
            if (priceTier != null && priceTier.isNotEmpty)
              _buildRestaurantDetailChip(priceTier, const Color.fromARGB(255, 253, 139, 69)),
            ...tags.map((t) => _buildRestaurantDetailChip(t, const Color.fromARGB(255, 100, 100, 100))),
          ],
        ),
      ],
    );
  }

  /// Resets the app state.
  void _resetApp() {
    setState(() {
      _helpMeDecideMode = false;
      _randomChoiceMode = false;
      _chosenRestaurant = null;
      _optionA = null;
      _optionB = null;
    });
  }

  /// Picks a random restaurant from the filtered list and shows it.
  void _chooseRandom() {
    final pool = _filteredPool;
    setState(() {
      _helpMeDecideMode = false;
      _randomChoiceMode = true;
      pool.shuffle();
      _chosenRestaurant = pool.isNotEmpty ? pool.first : null;
      _optionA = null;
      _optionB = null;
    });
  }

  /// Sets the screen to show head-to-head mode (two restaurants to compare).
  void _startHeadToHead() {
    final pool = _filteredPool;
    setState(() {
      _randomChoiceMode = false;
      _helpMeDecideMode = true;
      pool.shuffle();

      if (pool.length >= 2) {
        _optionA = pool[0];
        _optionB = pool[1];
      } else if (pool.isNotEmpty) {
        _chosenRestaurant = pool.first;
        _optionA = null;
        _optionB = null;
      } else {
        _chosenRestaurant = null;
        _optionA = null;
        _optionB = null;
      }
    });
  }

  /// Picks a winner between two restaurants and removes the loser from the pool.
  void _pickWinner(String winner, String loser) {
    setState(() {
      _restaurants.remove(loser);
      _chosenRestaurant = winner;

      final pool = _filteredPool;
      if (pool.length >= 2) {
        _optionA = winner;
        final nextIndex = pool.indexWhere((r) => r != winner);
        if (nextIndex != -1) {
          _optionB = pool[nextIndex];
        } else {
          _optionB = null;
        }
      } else {
        _optionA = null;
        _optionB = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadRestaurants,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "IDK, What do you want?",
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
              colors: [Color.fromARGB(255, 47, 168, 156), Color(0xFF40E0D0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => FilterScreen(
                        restaurants: _restaurantDetails,
                        activeCuisines: _activeCuisines,
                        activeTypes: _activeTypes,
                        activePriceTiers: _activePriceTiers,
                        onSave: () async {
                          await _loadFilters();
                        },
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SettingsScreen(
                        restaurantPreferences: _restaurantPreferences,
                        onSave: (newPreferences) {
                          setState(() {
                            _restaurantPreferences = newPreferences;
                          });
                        },
                      ),
                ),
              );
            },
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
        child: Center(
          child:
              _helpMeDecideMode
                  ? _buildHelpMeDecideView()
                  : _randomChoiceMode
                  ? _buildRandomChoiceView()
                  : _buildDefaultView(),
        ),
      ),
    );
  }

  /// The default view with "Choose Random" and "Help Me Decide."
  Widget _buildDefaultView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Not sure where to eat? \nLet's decide!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _chooseRandom,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color.fromARGB(255, 253, 139, 69),
            shadowColor: Colors.black.withAlpha(10),
            elevation: 5,
          ),
          child: const Text(
            "Choose For Me",
            style: TextStyle(
              color: Color.fromARGB(255, 35, 38, 40),
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _startHeadToHead,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color.fromARGB(255, 253, 139, 69),
            shadowColor: Colors.black.withAlpha(10),
            elevation: 5,
          ),
          child: const Text(
            "Help Me Decide",
            style: TextStyle(
              color: Color.fromARGB(255, 35, 38, 40),
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// The view for a random choice result.
  Widget _buildRandomChoiceView() {
    if (_chosenRestaurant != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Random choice:",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              _chosenRestaurant!,
              style: const TextStyle(
                color: Color(0xFF40E0D0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildRestaurantMeta(_getRestaurantDetails(_chosenRestaurant!)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetApp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color.fromARGB(255, 253, 139, 69),
                shadowColor: Colors.black.withAlpha(10),
                elevation: 5,
              ),
              child: const Text(
                "Start Over",
                style: TextStyle(
                  color: Color.fromARGB(255, 35, 38, 40),
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "No restaurants available.",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed:
              () => setState(() {
                _helpMeDecideMode = false;
                _randomChoiceMode = false;
              }),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color.fromARGB(255, 253, 139, 69),
            shadowColor: Colors.black.withAlpha(10),
            elevation: 5,
          ),
          child: const Text(
            "Return Home",
            style: TextStyle(
              color: Color.fromARGB(255, 35, 38, 40),
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// The head-to-head view: pick between two restaurants, or show the final winner.
  Widget _buildHelpMeDecideView() {
    if (_optionA != null && _optionB != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Which one do you prefer?",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _pickWinner(_optionA!, _optionB!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color.fromARGB(255, 253, 139, 69),
              shadowColor: Colors.black.withAlpha(10),
              elevation: 5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _optionA!,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 35, 38, 40),
                    fontSize: 20,
                  ),
                ),
                _buildRestaurantMeta(_getRestaurantDetails(_optionA!)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _pickWinner(_optionB!, _optionA!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color.fromARGB(255, 253, 139, 69),
              shadowColor: Colors.black.withAlpha(10),
              elevation: 5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _optionB!,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 35, 38, 40),
                    fontSize: 20,
                  ),
                ),
                _buildRestaurantMeta(_getRestaurantDetails(_optionB!)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _resetApp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color.fromARGB(255, 72, 80, 85),
                  shadowColor: Colors.black.withAlpha(10),
                  elevation: 5,
                ),
                child: const Text(
                  "Start Over",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_chosenRestaurant != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "The winner is:",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              _chosenRestaurant!,
              style: const TextStyle(
                color: Color(0xFF40E0D0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildRestaurantMeta(_getRestaurantDetails(_chosenRestaurant!)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetApp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color.fromARGB(255, 253, 139, 69),
                shadowColor: Colors.black.withAlpha(10),
                elevation: 5,
              ),
              child: const Text(
                "Start Over",
                style: TextStyle(
                  color: Color.fromARGB(255, 35, 38, 40),
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "No restaurants available.",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed:
              () => setState(() {
                _helpMeDecideMode = false;
                _randomChoiceMode = false;
              }),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color.fromARGB(255, 253, 139, 69),
            shadowColor: Colors.black.withAlpha(10),
            elevation: 5,
          ),
          child: const Text(
            "Return Home",
            style: TextStyle(
              color: Color.fromARGB(255, 35, 38, 40),
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
