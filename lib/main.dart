import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings.dart';
import 'filter_screen.dart';
import 'location_service.dart';
import 'share_service.dart';
import 'onboarding.dart';
import 'how_it_works.dart';
import 'demo_service.dart';
import 'restaurant_detail.dart';
import 'favorites_list_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'widgets/gradient_button.dart';
import 'widgets/gradient_text.dart';
import 'widgets/glow_orb.dart';

void main() {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final themeProvider = ThemeProvider();
    runApp(MyApp(themeProvider: themeProvider));
  } catch (e) {
    rethrow;
  }
}

class MyApp extends StatefulWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _onboardingFuture;

  @override
  void initState() {
    super.initState();
    _onboardingFuture = OnboardingService.hasCompletedOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return ListenableBuilder(
        listenable: widget.themeProvider,
        builder: (context, _) {
          return MaterialApp(
            title: 'IDK, What do you want?',
            debugShowCheckedModeBanner: false,
            themeMode: widget.themeProvider.themeMode,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            home: FutureBuilder<bool>(
              future: _onboardingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Scaffold(body: SizedBox.shrink());
                }
                if (snapshot.data != true) {
                  return OnboardingScreen(
                    onComplete: () => setState(() {
                      _onboardingFuture = Future.value(true);
                      OnboardingService.markOnboardingComplete();
                    }),
                  );
                }
                return MyHomePage(themeProvider: widget.themeProvider);
              },
            ),
          );
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// The stateful widget for your app's main screen.
class MyHomePage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const MyHomePage({super.key, required this.themeProvider});

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

  // History state
  Map<String, DateTime> _history = {};
  bool _avoidRepeats = true;

  // Filter state
  Set<String> _activeCuisines = {};
  Set<String> _activeTypes = {};
  Set<String> _activePriceTiers = {};

  // Location state
  Position? _userPosition;
  double _maxDistanceMiles = 10.0;
  // Flags to manage app modes
  bool _helpMeDecideMode = false;
  bool _randomChoiceMode = false;

  // Onboarding / first-run tooltip
  bool _hasSeenHowItWorks = false;

  // App links subscription for invite links
  StreamSubscription<Uri>? _appLinksSub;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _appLinksSub = ShareService.incomingLinks.listen((uri) {
      _handleIncomingLink(uri);
    });
  }

  @override
  void dispose() {
    _appLinksSub?.cancel();
    super.dispose();
  }

  /// Handle incoming app links (e.g. invite links).
  void _handleIncomingLink(Uri uri) {
    if (uri.scheme != 'idkyoupick' || uri.host != 'invite') return;
    final cuisines = uri.queryParameters['cuisines']?.split(',') ?? [];
    final types = uri.queryParameters['types']?.split(',') ?? [];
    final prices = uri.queryParameters['prices']?.split(',') ?? [];
    final distanceStr = uri.queryParameters['distance'];
    final distance = distanceStr != null ? double.tryParse(distanceStr) : null;

    setState(() {
      _activeCuisines = cuisines.where((s) => s.isNotEmpty).toSet();
      _activeTypes = types.where((s) => s.isNotEmpty).toSet();
      _activePriceTiers = prices.where((s) => s.isNotEmpty).toSet();
      if (distance != null && distance > 0) _maxDistanceMiles = distance;
    });
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final demo = await DemoService.isEnabled();
      await _loadRestaurants(demoMode: demo);
      await _loadFilters();
      await _loadDistanceFilter();
      await _loadHistory();
      final seenHowItWorks = prefs.getBool('has_seen_how_it_works') ?? false;
      _userPosition = await LocationService.determinePosition();
      setState(() {
        _restaurantPreferences = {
          for (var item in _restaurants) item: prefs.getBool(item) ?? true,
        };
        _hasSeenHowItWorks = seenHowItWorks;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Initialization failed.";
      });
    }
  }

  Future<void> _loadRestaurants({bool demoMode = false}) async {
    try {
      if (demoMode) {
        final demoData = DemoService.generateFakeRestaurants();
        setState(() {
          _restaurantDetails = demoData;
          _restaurants = demoData.map((r) => r['name'] as String).toList();
        });
        return;
      }
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

  /// Load saved distance filter state from SharedPreferences.
  Future<void> _loadDistanceFilter() async {
    final prefs = await SharedPreferences.getInstance();
    _maxDistanceMiles = prefs.getDouble('filter_max_distance') ?? 10.0;
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

  /// Returns the pool of restaurants after applying preferences, active filters, and distance.
  List<String> get _filteredPool {
    List<Map<String, dynamic>> pool;
    if (_restaurantDetails.isEmpty) {
      pool = _restaurants
          .where((r) => _restaurantPreferences[r] ?? true)
          .map((r) => <String, dynamic>{'name': r})
          .toList();
    } else {
      pool = _restaurantDetails.where((r) {
        final name = r['name'] as String;
        if (!(_restaurantPreferences[name] ?? true)) return false;
        if (_activeCuisines.isNotEmpty && !_activeCuisines.contains(r['cuisine'])) return false;
        if (_activeTypes.isNotEmpty && !_activeTypes.contains(r['type'])) return false;
        if (_activePriceTiers.isNotEmpty && !_activePriceTiers.contains(r['priceTier'])) return false;
        return true;
      }).toList();
    }

    if (_userPosition != null && _maxDistanceMiles > 0) {
      final lat = _userPosition!.latitude;
      final lng = _userPosition!.longitude;
      pool = pool.where((r) {
        final rLat = r['lat'] as double?;
        final rLng = r['lng'] as double?;
        if (rLat == null || rLng == null) return true; // keep items with no coords
        final d = LocationService.distanceInMiles(lat, lng, rLat, rLng);
        return d <= _maxDistanceMiles;
      }).toList();
    }

    final names = pool.map((r) => r['name'] as String).toList();
    if (_avoidRepeats && _history.isNotEmpty) {
      return names.where((n) => !_history.containsKey(n)).toList();
    }
    return names;
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('restaurant_history');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = json.decode(jsonStr);
        setState(() {
          _history = {
            for (var entry in decoded.entries)
              entry.key: DateTime.parse(entry.value as String),
          };
        });
      } catch (_) {
        _history = {};
      }
    }
    final avoid = prefs.getBool('avoid_repeats');
    if (avoid != null) _avoidRepeats = avoid;
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = { for (var e in _history.entries) e.key: e.value.toIso8601String() };
    await prefs.setString('restaurant_history', json.encode(encoded));
    await prefs.setBool('avoid_repeats', _avoidRepeats);
  }

  Future<void> _markTried(String name) async {
    setState(() {
      _history[name] = DateTime.now();
    });
    await _saveHistory();
    _resetApp();
  }

  Future<void> _removeFromHistory(String name) async {
    setState(() {
      _history.remove(name);
    });
    await _saveHistory();
  }

  Future<void> _clearHistory() async {
    setState(() {
      _history.clear();
    });
    await _saveHistory();
  }

  Future<void> _dismissHowItWorks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_how_it_works', true);
    if (!mounted) return;
    setState(() {
      _hasSeenHowItWorks = true;
    });
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final entries = _history.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'History (Tried)',
                      style: TextStyle(
                        color: AppColors.of(context).textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () { Navigator.pop(ctx); _clearHistory(); },
                      icon: Icon(Icons.delete_forever,
                        color: AppColors.of(context).danger, size: 18),
                      label: Text('Clear',
                        style: TextStyle(color: AppColors.of(context).danger)),
                    ),
                  ],
                ),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No restaurants marked as tried yet.',
                      style: TextStyle(color: AppColors.of(context).textSecondary),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final e = entries[index];
                        final dateStr = '${e.value.month}/${e.value.day}/${e.value.year}';
                        return ListTile(
                          title: Text(e.key,
                            style: TextStyle(color: AppColors.of(context).textPrimary)),
                          subtitle: Text(dateStr,
                            style: TextStyle(color: AppColors.of(context).textMuted)),
                          trailing: IconButton(
                            icon: Icon(Icons.close,
                              color: AppColors.of(context).textMuted),
                            onPressed: () => _removeFromHistory(e.key),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Share the current winner via system share sheet.
  Future<void> _handleShareWinner() async {
    final name = _chosenRestaurant;
    if (name == null) return;
    final details = _getRestaurantDetails(name);
    await ShareService.shareWinner(name, details);
  }

  /// Generate and share an invite link encoding current filters.
  Future<void> _handleShareInvite() async {
    final url = ShareService.generateInviteLink(
      cuisines: _activeCuisines,
      types: _activeTypes,
      priceTiers: _activePriceTiers,
      maxDistance: _maxDistanceMiles,
    );
    await ShareService.shareInviteLink(url);
  }

  /// Show bottom sheet with share options.
  void _showShareSheet() {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_chosenRestaurant != null)
                  ListTile(
                    leading: Icon(Icons.restaurant, color: colors.primary),
                    title: Text('Share winner', style: TextStyle(color: colors.textPrimary)),
                    subtitle: Text(_chosenRestaurant!, style: TextStyle(color: colors.textSecondary)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleShareWinner();
                    },
                  ),
                ListTile(
                  leading: Icon(Icons.link, color: colors.secondary),
                  title: Text('Invite link', style: TextStyle(color: colors.textPrimary)),
                  subtitle: Text('Send filters to a friend', style: TextStyle(color: colors.textSecondary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleShareInvite();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantDetailChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
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
    final colors = AppColors.of(context);

    return Column(
      children: [
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            if (cuisine != null && cuisine.isNotEmpty)
              _buildRestaurantDetailChip(cuisine, colors.primary, colors.chipTextLight),
            if (type != null && type.isNotEmpty)
              _buildRestaurantDetailChip(type, colors.primary, colors.chipTextLight),
            if (priceTier != null && priceTier.isNotEmpty)
              _buildRestaurantDetailChip(priceTier, colors.secondary, colors.chipTextLight),
            ...tags.map((t) => _buildRestaurantDetailChip(t, colors.chipDefaultBg, colors.textPrimary)),
            _buildDistanceMeta(details),
          ],
        ),
      ],
    );
  }

  /// Compute distance from user to this restaurant and return a chip, or nothing if no location.
  Widget _buildDistanceMeta(Map<String, dynamic>? details) {
    if (details == null || _userPosition == null) return const SizedBox.shrink();
    final rLat = details['lat'] as double?;
    final rLng = details['lng'] as double?;
    if (rLat == null || rLng == null) return const SizedBox.shrink();
    final d = LocationService.distanceInMiles(
      _userPosition!.latitude,
      _userPosition!.longitude,
      rLat,
      rLng,
    );
    final colors = AppColors.of(context);
    return _buildRestaurantDetailChip(
      '${d.toStringAsFixed(1)} mi',
      colors.primary,
      colors.chipTextLight,
    );
  }

  /// Action URL helpers
  Future<void> _openMaps(Map<String, dynamic> details) async {
    final lat = details['lat'] as double?;
    final lng = details['lng'] as double?;
    if (lat == null || lng == null) return;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openDoorDash(Map<String, dynamic> details) async {
    final name = details['name'] as String? ?? '';
    final uri = Uri.parse('https://www.doordash.com/search/store/$name/');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callRestaurant(Map<String, dynamic> details) async {
    final phone = details['phone'] as String?;
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWebsite(Map<String, dynamic> details) async {
    final url = details['website'] as String?;
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Build action button chips: Maps, DoorDash, Call, Website
  Widget _buildActionButtons(Map<String, dynamic>? details) {
    if (details == null) return const SizedBox.shrink();
    final hasCoords = details['lat'] != null && details['lng'] != null;
    final hasPhone = (details['phone'] as String?)?.isNotEmpty ?? false;
    final hasWebsite = (details['website'] as String?)?.isNotEmpty ?? false;
    final colors = AppColors.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (hasCoords)
          GradientButton(
            isSecondary: false,
            icon: Icons.map,
            label: 'Maps',
            onPressed: () => _openMaps(details),
          ),
        GradientButton(
          isSecondary: true,
          icon: Icons.delivery_dining,
          label: 'DoorDash',
          onPressed: () => _openDoorDash(details),
        ),
        if (hasPhone)
          ElevatedButton.icon(
            onPressed: () => _callRestaurant(details),
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.chipDefaultBg,
              foregroundColor: colors.textPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        if (hasWebsite)
          ElevatedButton.icon(
            onPressed: () => _openWebsite(details),
            icon: const Icon(Icons.language, size: 16),
            label: const Text('Website'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.chipDefaultBg,
              foregroundColor: colors.textPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
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
    final pool = List<String>.from(_filteredPool);
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

  /// Picks a winner between two restaurants and continues the bracket with a new challenger.
  void _pickWinner(String winner, String loser) {
    setState(() {
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
                style: TextStyle(color: AppColors.of(context).danger),
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

    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "IDK, What do you want?",
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
          Stack(
            children: [
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
                            maxDistance: _maxDistanceMiles,
                            onDistanceChanged: (value) {
                              setState(() {
                                _maxDistanceMiles = value;
                              });
                            },
                            onSave: () async {
                              await _loadFilters();
                              await _loadDistanceFilter();
                            },
                          ),
                    ),
                  );
                },
              ),
              if (_activeCuisines.isNotEmpty ||
                  _activeTypes.isNotEmpty ||
                  _activePriceTiers.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistorySheet,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareSheet,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => FavoritesListScreen(
                        restaurants: _restaurantDetails,
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
                        themeProvider: widget.themeProvider,
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors.backgroundGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const GlowOrb(size: 300, alignment: Alignment.topLeft),
          const GlowOrb(
            size: 250,
            alignment: Alignment.bottomRight,
            colors: [Color.fromRGBO(249, 115, 22, 0.06), Colors.transparent],
          ),
          SafeArea(
            child: Center(
              child:
                  _helpMeDecideMode
                      ? _buildHelpMeDecideView()
                      : _randomChoiceMode
                      ? _buildRandomChoiceView()
                      : _buildDefaultView(),
            ),
          ),
        ],
      ),
    );
  }

  /// The default view with "Choose Random" and "Help Me Decide."
  Widget _buildDefaultView() {
    final colors = AppColors.of(context);
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Not sure where to eat? \nLet's decide!",
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textPrimary, fontSize: 20),
            ),
            const SizedBox(height: 20),
            GradientButton(
              isSecondary: true,
              label: "Choose For Me",
              onPressed: _chooseRandom,
            ),
            const SizedBox(height: 30),
            GradientButton(
              isSecondary: true,
              label: "Help Me Decide",
              onPressed: _startHeadToHead,
            ),
          ],
        ),
        if (!_hasSeenHowItWorks) HowItWorksOverlay(onDismiss: _dismissHowItWorks),
      ],
    );
  }

  /// The view for a random choice result.
  Widget _buildRandomChoiceView() {
    if (_chosenRestaurant != null) {
      final colors = AppColors.of(context);
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Random choice:",
              style: TextStyle(color: colors.textPrimary, fontSize: 20),
            ),
            const SizedBox(height: 10),
            GradientText(
              text: _chosenRestaurant!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            _buildRestaurantMeta(_getRestaurantDetails(_chosenRestaurant!)),
            _buildActionButtons(_getRestaurantDetails(_chosenRestaurant!)),
            const SizedBox(height: 12),
            GradientButton(
              isSecondary: false,
              icon: Icons.info_outline,
              label: "View Details",
              onPressed: () {
                final details = _getRestaurantDetails(_chosenRestaurant!);
                if (details != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailScreen(restaurant: details),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            GradientButton(
              isSecondary: true,
              icon: Icons.share,
              label: "Share Winner",
              onPressed: _handleShareWinner,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _markTried(_chosenRestaurant!),
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Tried it'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.chipDefaultBg,
                foregroundColor: colors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 12),
            GradientButton(
              isSecondary: true,
              label: "Start Over",
              onPressed: _resetApp,
            ),
          ],
        ),
      );
    }
    final colors = AppColors.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.filter_alt_off, color: colors.textSecondary, size: 48),
        const SizedBox(height: 12),
        Text(
          "No restaurants match your filters.",
          style: TextStyle(color: colors.textPrimary, fontSize: 20),
        ),
        const SizedBox(height: 20),
        GradientButton(
          isSecondary: true,
          label: "Clear Filters",
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('filter_cuisines');
            await prefs.remove('filter_types');
            await prefs.remove('filter_prices');
            await _loadFilters();
            setState(() {
              _randomChoiceMode = false;
              _chosenRestaurant = null;
            });
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() {
            _helpMeDecideMode = false;
            _randomChoiceMode = false;
          }),
          child: Text(
            "Return Home",
            style: TextStyle(color: colors.textSecondary, fontSize: 16),
          ),
        ),
      ],
    );
  }

  /// The head-to-head view: pick between two restaurants, or show the final winner.
  Widget _buildHelpMeDecideView() {
    if (_optionA != null && _optionB != null) {
      final colors = AppColors.of(context);
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Which one do you prefer?",
            style: TextStyle(color: colors.textPrimary, fontSize: 20),
          ),
          const SizedBox(height: 20),
          GradientButton(
            isSecondary: true,
            onPressed: () => _pickWinner(_optionA!, _optionB!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _optionA!,
                  style: const TextStyle(fontSize: 20),
                ),
                _buildRestaurantMeta(_getRestaurantDetails(_optionA!)),
                TextButton(
                  onPressed: () {
                    final details = _getRestaurantDetails(_optionA!);
                    if (details != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailScreen(restaurant: details),
                        ),
                      );
                    }
                  },
                  child: const Text('View Details', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GradientButton(
            isSecondary: true,
            onPressed: () => _pickWinner(_optionB!, _optionA!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _optionB!,
                  style: const TextStyle(fontSize: 20),
                ),
                _buildRestaurantMeta(_getRestaurantDetails(_optionB!)),
                TextButton(
                  onPressed: () {
                    final details = _getRestaurantDetails(_optionB!);
                    if (details != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailScreen(restaurant: details),
                        ),
                      );
                    }
                  },
                  child: const Text('View Details', style: TextStyle(fontSize: 12)),
                ),
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
                  backgroundColor: colors.chipDefaultBg,
                  shadowColor: colors.shadow,
                  elevation: 5,
                ),
                child: Text(
                  "Start Over",
                  style: TextStyle(color: colors.textPrimary, fontSize: 20),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_chosenRestaurant != null) {
      final colors = AppColors.of(context);
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "The winner is:",
              style: TextStyle(color: colors.textPrimary, fontSize: 20),
            ),
            const SizedBox(height: 10),
            GradientText(
              text: _chosenRestaurant!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            _buildRestaurantMeta(_getRestaurantDetails(_chosenRestaurant!)),
            _buildActionButtons(_getRestaurantDetails(_chosenRestaurant!)),
            const SizedBox(height: 12),
            GradientButton(
              isSecondary: false,
              icon: Icons.info_outline,
              label: "View Details",
              onPressed: () {
                final details = _getRestaurantDetails(_chosenRestaurant!);
                if (details != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailScreen(restaurant: details),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            GradientButton(
              isSecondary: true,
              icon: Icons.share,
              label: "Share Winner",
              onPressed: _handleShareWinner,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _markTried(_chosenRestaurant!),
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Tried it'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.chipDefaultBg,
                foregroundColor: colors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 12),
            GradientButton(
              isSecondary: true,
              label: "Start Over",
              onPressed: _resetApp,
            ),
          ],
        ),
      );
    }

    final colors = AppColors.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.filter_alt_off, color: colors.textSecondary, size: 48),
        const SizedBox(height: 12),
        Text(
          "No restaurants match your filters.",
          style: TextStyle(color: colors.textPrimary, fontSize: 20),
        ),
        const SizedBox(height: 20),
        GradientButton(
          isSecondary: true,
          label: "Clear Filters",
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('filter_cuisines');
            await prefs.remove('filter_types');
            await prefs.remove('filter_prices');
            await _loadFilters();
            setState(() {
              _helpMeDecideMode = false;
              _chosenRestaurant = null;
              _optionA = null;
              _optionB = null;
            });
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() {
            _helpMeDecideMode = false;
            _randomChoiceMode = false;
          }),
          child: Text(
            "Return Home",
            style: TextStyle(color: colors.textSecondary, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
