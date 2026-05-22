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
import 'services/haptics_service.dart';
import 'services/review_prompt.dart';
import 'demo_service.dart';
import 'restaurant_detail.dart';
import 'favorites_list_screen.dart';
import 'search_screen.dart';
import 'price_bracket_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'widgets/liquid_glass.dart';
import 'widgets/liquid_glass_app_bar.dart';
import 'widgets/liquid_glass_button.dart';
import 'widgets/liquid_glass_scaffold.dart';

import 'services/notification_service.dart';
import 'services/lunch_suggestion_service.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.4)),
            ),
              child: MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'IDK, What do you want?',
              debugShowCheckedModeBanner: false,
              themeMode: widget.themeProvider.themeMode,
              theme: widget.themeProvider.lightThemeWithExtension(AppTheme.lightTheme()),
              darkTheme: widget.themeProvider.darkThemeWithExtension(AppTheme.darkTheme()),
              scrollBehavior: const _AppScrollBehavior(),
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
  bool _useLocation = true;
  // Flags to manage app modes
  bool _helpMeDecideMode = false;
  bool _randomChoiceMode = false;

  // Track eliminated restaurants in Help Me Decide bracket
  final Set<String> _eliminated = {};

  // Onboarding / first-run tooltip
  bool _hasSeenHowItWorks = false;

  // App links subscription for invite links
  StreamSubscription<Uri>? _appLinksSub;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setupNotificationTap();
    _appLinksSub = ShareService.incomingLinks.listen((uri) {
      _handleIncomingLink(uri);
    });
  }

  @override
  void dispose() {
    _appLinksSub?.cancel();
    super.dispose();
  }

  /// Handle incoming app links (e.g. invite links, restaurant deep links).
  void _handleIncomingLink(Uri uri) {
    if (uri.scheme != 'idkyoupick') return;

    // Handle restaurant deep links: idkyoupick://restaurant/<slug>
    if (uri.host == 'restaurant') {
      final slug = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
      final found = _restaurantDetails.where((r) {
        return ShareService.generateSlug(r['name'] as String) == slug;
      }).toList();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (found.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailScreen(restaurant: found.first),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restaurant not found. It may have been removed or renamed.'),
            ),
          );
        }
      });
    }
      return;
    }

    if (uri.host != 'invite') return;
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

  /// Wire up notification tap handler for cold-start and warm/hot taps.
  void _setupNotificationTap() {
    NotificationService.onNotificationTap = (payload) {
      _navigateToLunchSuggestion();
    };
  }

  /// Pick a fresh lunch suggestion and navigate to RestaurantDetailScreen.
  Future<void> _navigateToLunchSuggestion() async {
    final suggestion = await LunchSuggestionService.pickLunchSuggestion();
    if (suggestion != null) {
      final name = suggestion['name'] as String;
      final details = _getRestaurantDetails(name);
      if (details != null && _navigatorKey.currentContext != null) {
        await LunchSuggestionService.recordSuggestion(name);
        Navigator.of(_navigatorKey.currentContext!).push(
          _fadeSlideRoute(RestaurantDetailScreen(restaurant: details)),
        );
      }
    }
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
      _useLocation = prefs.getBool('use_location') ?? true;
      if (_useLocation) {
        try {
          // Never request permission on launch — silently disable if denied.
          final permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            _useLocation = false;
            await prefs.setBool('use_location', false);
          } else {
            _userPosition = await LocationService.determinePosition();
            if (_userPosition == null) {
              _useLocation = false;
              await prefs.setBool('use_location', false);
            }
          }
        } catch (_) {
          _useLocation = false;
          await prefs.setBool('use_location', false);
        }
      }
      await _loadCustomRestaurants();
      // Check cold-start notification tap
      final launchPayload = await NotificationService.getLaunchPayload();
      setState(() {
        _restaurantPreferences = {
          for (var item in _restaurants) item: prefs.getBool(item) ?? true,
        };
        _hasSeenHowItWorks = seenHowItWorks;
      });
      if (launchPayload != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToLunchSuggestion();
        });
      }
      final initialLink = await ShareService.getInitialLink();
      if (initialLink != null) _handleIncomingLink(initialLink);
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

  /// Load custom restaurants and merge them into the pool.
  Future<void> _loadCustomRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getStringList('customRestaurants') ?? [];
    if (custom.isEmpty) return;
    setState(() {
      for (final name in custom) {
        if (!_restaurantDetails.any((r) => r['name'] == name)) {
          _restaurantDetails.add({
            'name': name,
            'cuisine': 'Custom',
            'type': 'Custom',
            'priceTier': '\$',
            'lat': null,
            'lng': null,
          });
        }
        if (!_restaurants.contains(name)) {
          _restaurants.add(name);
        }
      }
    });
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

    if (_useLocation && _userPosition != null && _maxDistanceMiles > 0) {
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

  String _getEmptyPoolMessage() {
    if (_restaurantPreferences.isNotEmpty &&
        _restaurantPreferences.values.every((v) => v == false)) {
      return "All restaurants are disabled in Settings. Enable some restaurants to continue.";
    }
    if (_activeCuisines.isEmpty && _activeTypes.isEmpty && _activePriceTiers.isEmpty) {
      if (_useLocation && _userPosition != null && _maxDistanceMiles > 0) {
        return "No restaurants within ${_maxDistanceMiles.toStringAsFixed(0)} miles of your location. Try increasing the distance or adding local restaurants.";
      }
    }
    return "No restaurants match your filters. Try clearing filters.";
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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final entries = _history.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return SafeArea(
          child: LiquidGlass(
            margin: EdgeInsets.zero,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                        fontWeight: FontWeight.w600,
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
                            tooltip: 'Remove from history',
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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: LiquidGlass(
            margin: EdgeInsets.zero,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      fontWeight: FontWeight.w600,
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
          ),
        );
      },
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

  /// Resets the app state.
  void _resetApp() {
    HapticsService.light();
    setState(() {
      _helpMeDecideMode = false;
      _randomChoiceMode = false;
      _chosenRestaurant = null;
      _optionA = null;
      _optionB = null;
      _eliminated.clear();
    });
  }

  /// Picks a random restaurant from the filtered list and shows it.
  void _chooseRandom() {
    final pool = List<String>.from(_filteredPool);
    pool.shuffle();
    setState(() {
      _helpMeDecideMode = false;
      _randomChoiceMode = true;
      _chosenRestaurant = pool.isNotEmpty ? pool.first : null;
      _optionA = null;
      _optionB = null;
      _eliminated.clear();
    });
    HapticsService.medium();
    ReviewPrompt.maybeShow();
  }

  /// Start a bracket battle limited to a single price tier.
  /// Temporarily applies the tier as a filter, starts head-to-head, then restores filters.
  void _startPriceBracketBattle(String tier) {
    final previousPriceTiers = Set<String>.from(_activePriceTiers);
    setState(() {
      _activePriceTiers = {tier};
    });
    _startHeadToHead();
    // Schedule restoration so the next build cycle uses the temporary filter,
    // then reverts it behind the scenes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _activePriceTiers = previousPriceTiers;
      });
    });
  }

  /// Sets the screen to show head-to-head mode (two restaurants to compare).
  void _startHeadToHead() {
    final pool = List<String>.from(_filteredPool);
    pool.shuffle();
    setState(() {
      _randomChoiceMode = false;
      _helpMeDecideMode = true;
      _eliminated.clear();

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
    if (pool.isNotEmpty) HapticsService.medium();
  }

  /// Picks a winner between two restaurants and continues the bracket with a new challenger.
  void _pickWinner(String winner, String loser) {
    HapticsService.medium();
    setState(() {
      _chosenRestaurant = winner;
      _eliminated.add(loser);

      final pool = _filteredPool;
      final challengers = pool.where((r) => r != winner && !_eliminated.contains(r)).toList();
      if (challengers.isNotEmpty) {
        challengers.shuffle();
        _optionA = winner;
        _optionB = challengers.first;
      } else {
        _optionA = winner;
        _optionB = null;
      }
    });
    ReviewPrompt.maybeShow();
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

    return LiquidGlassScaffold(
      appBar: LiquidGlassAppBar(
        title: Semantics(
          header: true,
          child: Text(
            "IDK, What do you want?",
            style: TextStyle(
              color: colors.appBarText,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, size: 22),
            color: colors.textPrimary,
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesListScreen(
                    restaurants: _restaurantDetails,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 22),
            color: colors.textPrimary,
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    restaurantPreferences: _restaurantPreferences,
                    themeProvider: widget.themeProvider,
                    onSave: (newPreferences) {
                      setState(() {
                        _restaurantPreferences = newPreferences;
                      });
                    },
                    useLocation: _useLocation,
                    onLocationChanged: (enabled) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('use_location', enabled);
                      setState(() {
                        _useLocation = enabled;
                        if (!enabled) {
                          _userPosition = null;
                        }
                      });
                      if (enabled) {
                        final pos = await LocationService.determinePosition();
                        if (pos != null) {
                          setState(() {
                            _userPosition = pos;
                          });
                        }
                      }
                    },
                  ),
                ),
              );
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
        child: SafeArea(
          child: Center(
            child:
                _helpMeDecideMode
                    ? _buildHelpMeDecideView()
                    : _randomChoiceMode
                    ? _buildRandomChoiceView()
                    : _buildDefaultView(),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  /// The default view with "Choose Random" and "Help Me Decide."
  Widget _buildDefaultView() {
    final colors = AppColors.of(context);
    return Stack(
      children: [
        Center(
          child: LiquidGlass(
            blurSigma: 25,
            opacity: 0.18,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant, size: 48, color: colors.primary),
                const SizedBox(height: 16),
                Text(
                  "Not sure where to eat?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Let's decide!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 28),
                Semantics(
                  button: true,
                  label: 'Choose a random restaurant',
                  child: LiquidGlassButton(
                    label: "Choose For Me",
                    onPressed: _chooseRandom,
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Compare two restaurants head to head',
                  child: LiquidGlassButton(
                    label: "Help Me Decide",
                    onPressed: _startHeadToHead,
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Battle by price bracket',
                  child: LiquidGlassButton(
                    label: "Price Bracket Battle",
                    onPressed: () async {
                      final tier = await Navigator.push<String>(
                        context,
                        _fadeSlideRoute(const PriceBracketScreen()),
                      );
                      if (tier != null && mounted) {
                        _startPriceBracketBattle(tier);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!_hasSeenHowItWorks) HowItWorksOverlay(onDismiss: _dismissHowItWorks),
      ],
    );
  }

  /// The view for a random choice result.
  Widget _buildRandomChoiceView() {
    if (_chosenRestaurant != null) {
      final colors = AppColors.of(context);
      final details = _getRestaurantDetails(_chosenRestaurant!);
      final hasCoords = details != null && details['lat'] != null && details['lng'] != null;
      return LiquidGlass(
        blurSigma: 25,
        opacity: 0.18,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 40),
            Text(
              "Random choice:",
              style: TextStyle(color: colors.textPrimary, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              _chosenRestaurant!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
            const Spacer(flex: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: LiquidGlassButton(
                    icon: Icons.info_outline,
                    label: "View Details",
                    onPressed: () {
                      if (details != null) {
                        Navigator.push(
                          context,
                          _fadeSlideRoute(RestaurantDetailScreen(restaurant: details)),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: LiquidGlassButton(
                    icon: Icons.share,
                    label: "Share Winner",
                    onPressed: _handleShareWinner,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            LiquidGlassButton(
              label: "Start Over",
              onPressed: _resetApp,
            ),
            const Spacer(flex: 2),
            if (details != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasCoords)
                    Flexible(
                      child: LiquidGlassButton(
                        icon: Icons.map,
                        label: 'Maps',
                        onPressed: () => _openMaps(details),
                      ),
                    ),
                  if (hasCoords)
                    const SizedBox(width: 12),
                  Flexible(
                    child: LiquidGlassButton(
                      icon: Icons.delivery_dining,
                      label: 'DoorDash',
                      onPressed: () => _openDoorDash(details),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
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
          _getEmptyPoolMessage(),
          style: TextStyle(color: colors.textPrimary, fontSize: 20),
        ),
        const SizedBox(height: 20),
        LiquidGlassButton(
          label: "Clear Filters",
          onPressed: () async {
            HapticsService.light();
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
          LiquidGlassButton(
            onPressed: () => _pickWinner(_optionA!, _optionB!),
            child: SizedBox(
              width: 320,
              height: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _optionA!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  TextButton(
                    onPressed: () {
                      final details = _getRestaurantDetails(_optionA!);
                      if (details != null) {
                        Navigator.push(
                          context,
                          _fadeSlideRoute(RestaurantDetailScreen(restaurant: details)),
                        );
                      }
                    },
                    child: const Text('View Details', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          LiquidGlassButton(
            onPressed: () => _pickWinner(_optionB!, _optionA!),
            child: SizedBox(
              width: 320,
              height: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _optionB!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  TextButton(
                    onPressed: () {
                      final details = _getRestaurantDetails(_optionB!);
                      if (details != null) {
                        Navigator.push(
                          context,
                          _fadeSlideRoute(RestaurantDetailScreen(restaurant: details)),
                        );
                      }
                    },
                    child: const Text('View Details', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
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
      final isFinalWinner = _optionA != null && _optionB == null;
      final details = _getRestaurantDetails(_chosenRestaurant!);
      final hasCoords = details != null && details['lat'] != null && details['lng'] != null;
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 40),
            Text(
              isFinalWinner ? "Final Winner!" : "The winner is:",
              style: TextStyle(color: colors.textPrimary, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              _chosenRestaurant!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
            const Spacer(flex: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: LiquidGlassButton(
                    icon: Icons.info_outline,
                    label: "View Details",
                    onPressed: () {
                      if (details != null) {
                        Navigator.push(
                          context,
                          _fadeSlideRoute(RestaurantDetailScreen(restaurant: details)),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: LiquidGlassButton(
                    icon: Icons.share,
                    label: "Share Winner",
                    onPressed: _handleShareWinner,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            LiquidGlassButton(
              label: "Start Over",
              onPressed: _resetApp,
            ),
            const Spacer(flex: 2),
            if (details != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasCoords)
                    Flexible(
                      child: LiquidGlassButton(
                        icon: Icons.map,
                        label: 'Maps',
                        onPressed: () => _openMaps(details),
                      ),
                    ),
                  if (hasCoords)
                    const SizedBox(width: 12),
                  Flexible(
                    child: LiquidGlassButton(
                      icon: Icons.delivery_dining,
                      label: 'DoorDash',
                      onPressed: () => _openDoorDash(details),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
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
          _getEmptyPoolMessage(),
          style: TextStyle(color: colors.textPrimary, fontSize: 20),
        ),
        const SizedBox(height: 20),
        LiquidGlassButton(
          label: "Clear Filters",
          onPressed: () async {
            HapticsService.light();
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
              _eliminated.clear();
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

  /// Bottom action bar with Filter, History, Share, Search, Favorites, Settings.
  Widget _buildBottomActionBar() {
    final colors = AppColors.of(context);
    return LiquidGlass(
      blurSigma: 18,
      opacity: 0.12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_alt, size: 22),
                color: colors.textPrimary,
                tooltip: 'Filters',
                onPressed: () {
                  Navigator.push(
                    context,
                    _fadeSlideRoute(FilterScreen(
                      restaurants: _restaurantDetails,
                      activeCuisines: _activeCuisines,
                      activeTypes: _activeTypes,
                      activePriceTiers: _activePriceTiers,
                      maxDistance: _maxDistanceMiles,
                      useLocation: _useLocation,
                      onDistanceChanged: (value) {
                        setState(() {
                          _maxDistanceMiles = value;
                        });
                      },
                      onSave: () async {
                        await _loadFilters();
                        await _loadDistanceFilter();
                      },
                    )),
                  );
                },
              ),
              if (_activeCuisines.isNotEmpty ||
                  _activeTypes.isNotEmpty ||
                  _activePriceTiers.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history, size: 22),
            color: colors.textPrimary,
            tooltip: 'History',
            onPressed: _showHistorySheet,
          ),
          IconButton(
            icon: const Icon(Icons.share, size: 22),
            color: colors.textPrimary,
            tooltip: 'Share',
            onPressed: _showShareSheet,
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            color: colors.textPrimary,
            tooltip: 'Search',
            onPressed: () {
              Navigator.push(
                context,
                _fadeSlideRoute(SearchScreen(
                  restaurants: _restaurantDetails,
                  activeCuisines: _activeCuisines,
                  activeTypes: _activeTypes,
                  activePriceTiers: _activePriceTiers,
                  maxDistanceMiles: _maxDistanceMiles,
                  userPosition: _userPosition,
                  useLocation: _useLocation,
                )),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite, size: 22),
            color: colors.textPrimary,
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.push(
                context,
                _fadeSlideRoute(FavoritesListScreen(
                  restaurants: _restaurantDetails,
                )),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 22),
            color: colors.textPrimary,
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                _fadeSlideRoute(SettingsScreen(
                  restaurantPreferences: _restaurantPreferences,
                  themeProvider: widget.themeProvider,
                  onSave: (newPreferences) {
                    setState(() {
                      _restaurantPreferences = newPreferences;
                    });
                  },
                  useLocation: _useLocation,
                  onLocationChanged: (enabled) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('use_location', enabled);
                    setState(() {
                      _useLocation = enabled;
                      if (!enabled) {
                        _userPosition = null;
                      }
                    });
                    if (enabled) {
                      final pos = await LocationService.determinePosition();
                      if (pos != null) {
                        setState(() {
                          _userPosition = pos;
                        });
                      }
                    }
                  },
                )),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Fade + slight slide page transition.
  Route<T> _fadeSlideRoute<T>(Widget nextScreen) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => nextScreen,
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Global scroll behavior: smooth bouncing on both iOS and Android,
/// suppresses overscroll glow to match Aurora Frost aesthetic.
class _AppScrollBehavior extends ScrollBehavior {
  const _AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast);
  }
}
