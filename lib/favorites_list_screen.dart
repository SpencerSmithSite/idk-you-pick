import 'package:flutter/material.dart';
import 'favorites_service.dart';
import 'restaurant_detail.dart';
import 'theme/app_colors.dart';
import 'widgets/glass_card.dart';

class FavoritesListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> restaurants;

  const FavoritesListScreen({super.key, required this.restaurants});

  @override
  State<FavoritesListScreen> createState() => _FavoritesListScreenState();
}

class _FavoritesListScreenState extends State<FavoritesListScreen> {
  Set<String> _favorites = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesService.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = favs;
        _loading = false;
      });
    }
  }

  Future<void> _removeFavorite(String name) async {
    await FavoritesService.removeFavorite(name);
    await _loadFavorites();
  }

  Map<String, dynamic>? _resolveRestaurant(String name) {
    try {
      return widget.restaurants.firstWhere((r) => r['name'] == name);
    } catch (_) {
      return null;
    }
  }

  Widget _buildChip(String label, Color bg, Color fg) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
          'Favorites',
          style: TextStyle(
            color: colors.appBarText,
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.appBarText),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? Center(
                child: CircularProgressIndicator(color: colors.primary),
              )
            : _favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: colors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No favorites yet',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the heart on a restaurant to save it here.',
                          style: TextStyle(
                            color: colors.textSecondary.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final name = _favorites.elementAt(index);
                      final restaurant = _resolveRestaurant(name);
                      if (restaurant == null) {
                        return const SizedBox.shrink();
                      }

                      final cuisine = (restaurant['cuisine'] ?? '').toString();
                      final type = (restaurant['type'] ?? '').toString();
                      final price = (restaurant['priceTier'] ?? '').toString();
                      final distance = restaurant['distance'];

                      return Dismissible(
                        key: ValueKey(name),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: colors.dismissibleBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.delete, color: colors.favorite),
                        ),
                        onDismissed: (_) => _removeFavorite(name),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RestaurantDetailScreen(
                                  restaurant: restaurant,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          color: colors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        children: [
                                          if (cuisine.isNotEmpty)
                                            _buildChip(
                                              cuisine,
                                              colors.primary,
                                              colors.chipTextLight,
                                            ),
                                          if (type.isNotEmpty)
                                            _buildChip(
                                              type,
                                              colors.primary,
                                              colors.chipTextLight,
                                            ),
                                          if (price.isNotEmpty)
                                            _buildChip(
                                              price,
                                              colors.secondary,
                                              colors.chipTextLight,
                                            ),
                                          if (distance != null)
                                            _buildChip(
                                              '$distance mi',
                                              colors.chipDefaultBg,
                                              colors.textPrimary,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: colors.favorite,
                                  ),
                                  onPressed: () => _removeFavorite(name),
                                  tooltip: 'Remove from favorites',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
