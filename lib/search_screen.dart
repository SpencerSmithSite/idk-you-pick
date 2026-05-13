import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'widgets/glass_card.dart';
import 'restaurant_detail.dart';
import 'favorites_service.dart';
import 'location_service.dart';
import 'package:geolocator/geolocator.dart';

enum SortMode { name, distance, priceLow, cuisine, random }

class SearchScreen extends StatefulWidget {
  final List<Map<String, dynamic>> restaurants;
  final Set<String> activeCuisines;
  final Set<String> activeTypes;
  final Set<String> activePriceTiers;
  final double maxDistanceMiles;
  final Position? userPosition;
  final bool useLocation;

  const SearchScreen({
    super.key,
    required this.restaurants,
    required this.activeCuisines,
    required this.activeTypes,
    required this.activePriceTiers,
    required this.maxDistanceMiles,
    this.userPosition,
    this.useLocation = true,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  SortMode _sortMode = SortMode.name;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    List<Map<String, dynamic>> pool = List.from(widget.restaurants);

    // Respect active filters
    if (widget.activeCuisines.isNotEmpty) {
      pool = pool.where((r) => widget.activeCuisines.contains(r['cuisine'])).toList();
    }
    if (widget.activeTypes.isNotEmpty) {
      pool = pool.where((r) => widget.activeTypes.contains(r['type'])).toList();
    }
    if (widget.activePriceTiers.isNotEmpty) {
      pool = pool.where((r) => widget.activePriceTiers.contains(r['priceTier'])).toList();
    }
    if (widget.useLocation && widget.userPosition != null) {
      pool = pool.where((r) {
        final lat = r['lat'] as double?;
        final lng = r['lng'] as double?;
        if (lat == null || lng == null) return true;
        final d = LocationService.distanceBetween(
          widget.userPosition!.latitude,
          widget.userPosition!.longitude,
          lat,
          lng,
        );
        return d <= widget.maxDistanceMiles;
      }).toList();
    }

    // Text search
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      pool = pool.where((r) {
        final name = (r['name'] as String? ?? '').toLowerCase();
        final cuisine = (r['cuisine'] as String? ?? '').toLowerCase();
        final type = (r['type'] as String? ?? '').toLowerCase();
        final tags = (r['tags'] as List<dynamic>? ?? []).cast<String>().join(' ').toLowerCase();
        return name.contains(q) || cuisine.contains(q) || type.contains(q) || tags.contains(q);
      }).toList();
    }

    // Sort
    switch (_sortMode) {
      case SortMode.name:
        pool.sort((a, b) {
          final an = (a['name'] as String? ?? '').toLowerCase();
          final bn = (b['name'] as String? ?? '').toLowerCase();
          return an.compareTo(bn);
        });
      case SortMode.distance:
        if (widget.userPosition != null) {
          pool.sort((a, b) {
            final alat = a['lat'] as double?;
            final alng = a['lng'] as double?;
            final blat = b['lat'] as double?;
            final blng = b['lng'] as double?;
            final da = (alat != null && alng != null)
                ? LocationService.distanceBetween(
                    widget.userPosition!.latitude, widget.userPosition!.longitude, alat, alng)
                : double.infinity;
            final db = (blat != null && blng != null)
                ? LocationService.distanceBetween(
                    widget.userPosition!.latitude, widget.userPosition!.longitude, blat, blng)
                : double.infinity;
            return da.compareTo(db);
          });
        }
      case SortMode.priceLow:
        pool.sort((a, b) {
          final pa = _priceValue(a['priceTier'] as String?);
          final pb = _priceValue(b['priceTier'] as String?);
          return pa.compareTo(pb);
        });
      case SortMode.cuisine:
        pool.sort((a, b) {
          final ca = (a['cuisine'] as String? ?? '').toLowerCase();
          final cb = (b['cuisine'] as String? ?? '').toLowerCase();
          final cmp = ca.compareTo(cb);
          if (cmp != 0) return cmp;
          final na = (a['name'] as String? ?? '').toLowerCase();
          final nb = (b['name'] as String? ?? '').toLowerCase();
          return na.compareTo(nb);
        });
      case SortMode.random:
        pool.shuffle();
    }

    return pool;
  }

  int _priceValue(String? tier) {
    switch (tier) {
      case '\$':
        return 1;
      case '\$\$':
        return 2;
      case '\$\$\$':
        return 3;
      default:
        return 99;
    }
  }

  void _onSortSelected(SortMode mode) {
    setState(() => _sortMode = mode);
    Navigator.pop(context);
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return GlassCard(
          margin: EdgeInsets.zero,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sort by', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _sortTile(ctx, SortMode.name, 'Name (A–Z)', Icons.sort_by_alpha),
                _sortTile(ctx, SortMode.distance, 'Distance (nearest)', Icons.near_me),
                _sortTile(ctx, SortMode.priceLow, 'Price (low–high)', Icons.attach_money),
                _sortTile(ctx, SortMode.cuisine, 'Cuisine', Icons.local_dining),
                _sortTile(ctx, SortMode.random, 'Random', Icons.shuffle),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sortTile(BuildContext ctx, SortMode mode, String label, IconData icon) {
    final isActive = _sortMode == mode;
    final colors = AppColors.of(ctx);
    return ListTile(
      leading: Icon(icon, color: isActive ? colors.primary : colors.textSecondary),
      title: Text(label, style: TextStyle(color: isActive ? colors.primary : colors.textPrimary, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
      trailing: isActive ? Icon(Icons.check_circle, color: colors.primary) : null,
      onTap: () => _onSortSelected(mode),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSearchBar() {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: colors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search restaurants, cuisines, tags...',
                hintStyle: TextStyle(color: colors.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: colors.textMuted),
              tooltip: 'Clear search',
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
                _focusNode.requestFocus();
              },
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildResultTile(Map<String, dynamic> r) {
    final colors = AppColors.of(context);
    final name = r['name'] as String? ?? 'Restaurant';
    final cuisine = r['cuisine'] as String?;
    final type = r['type'] as String?;
    final price = r['priceTier'] as String?;
    final distance = r['distance'] as String?;
    final tags = (r['tags'] as List<dynamic>? ?? []).cast<String>();

    return FutureBuilder<bool>(
      future: FavoritesService.isFavorite(name),
      builder: (ctx, snap) {
        final isFav = snap.data ?? false;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.surfaceBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(name, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (cuisine != null)
                    _miniChip(cuisine, colors.primary),
                  if (type != null)
                    _miniChip(type, colors.secondary),
                  if (price != null)
                    _miniChip(price, colors.success),
                  if (distance != null)
                    _miniChip('$distance mi', colors.info),
                  ...tags.take(3).map((t) => _miniChip(t, colors.textMuted)),
                ],
              ),
            ),
            trailing: Icon(
              isFav ? Icons.favorite : Icons.chevron_right,
              color: isFav ? colors.favorite : colors.textMuted,
              size: 20,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: r)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final results = _filtered;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          TextButton.icon(
            onPressed: _showSortSheet,
            icon: Icon(Icons.sort, color: colors.primary),
            label: Text(
              'Sort',
              style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${results.length} result${results.length == 1 ? '' : 's'}',
                  style: TextStyle(color: colors.textMuted, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  _sortLabel(_sortMode),
                  style: TextStyle(color: colors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: colors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty ? 'No restaurants match your filters' : 'No results for "$_query"',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                        if (_query.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                            child: Text('Clear search', style: TextStyle(color: colors.primary)),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: results.length,
                    itemBuilder: (_, i) => _buildResultTile(results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(SortMode mode) {
    switch (mode) {
      case SortMode.name:
        return 'A–Z';
      case SortMode.distance:
        return 'Nearest';
      case SortMode.priceLow:
        return 'Price ↑';
      case SortMode.cuisine:
        return 'Cuisine';
      case SortMode.random:
        return 'Random';
    }
  }
}
