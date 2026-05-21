import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/app_colors.dart';
import 'widgets/liquid_glass.dart';
import 'widgets/liquid_glass_button.dart';
import 'favorites_service.dart';
import 'services/haptics_service.dart';
import 'share_service.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final fav = await FavoritesService.isFavorite(widget.restaurant['name'] as String);
    setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    HapticsService.light();
    await FavoritesService.toggleFavorite(widget.restaurant['name'] as String);
    await _loadFavorite();
  }

  String? _get(String key) {
    final val = widget.restaurant[key];
    if (val == null) return null;
    if (val is String && val.isEmpty) return null;
    return val.toString();
  }

  Future<void> _openMaps() async {
    final address = _get('address') ?? widget.restaurant['name'];
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address!)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callRestaurant() async {
    final phone = _get('phone');
    if (phone == null) return;
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openWebsite() async {
    final website = _get('website');
    if (website == null) return;
    final url = Uri.parse(website);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDoorDash() async {
    final name = widget.restaurant['name'];
    final url = Uri.parse(
      'https://www.doordash.com/search/store/${Uri.encodeComponent(name)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.restaurant['name'] as String? ?? 'Restaurant';
    final cuisine = _get('cuisine');
    final type = _get('type');
    final price = _get('priceTier');
    final distance = _get('distance');
    final address = _get('address');
    final phone = _get('phone');
    final website = _get('website');
    final tags = (widget.restaurant['tags'] as List<dynamic>?)?.cast<String>() ?? [];
    final rating = widget.restaurant['rating'] as num?;
    final hours = widget.restaurant['hours'] as Map<String, dynamic>?;
    final image = widget.restaurant['image'] as String?;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Semantics(
                button: true,
                label: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? colors.favorite : colors.surfaceIcon,
                  ),
                  onPressed: _toggleFavorite,
                  tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
              ),
              IconButton(
                icon: Icon(Icons.share, color: colors.surfaceIcon),
                onPressed: () {
                  ShareService.shareRestaurantLink(
                    ShareService.generateSlug(widget.restaurant['name'] as String),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Semantics(
                header: true,
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark ? colors.primaryGradient : colors.secondaryGradient,
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'restaurant_image_$name',
                    child: image != null
                        ? ClipOval(
                            child: Image.network(
                              image,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.restaurant,
                                size: 64,
                                color: colors.surfaceIcon,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.restaurant,
                            size: 64,
                            color: colors.surfaceIcon,
                          ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: LiquidGlass(
              blurSigma: 20,
              opacity: 0.15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating
                  if (rating != null) ...[
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$rating',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ 5',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Meta chips
                  Semantics(
                    label: 'Restaurant details',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (cuisine != null)
                          _buildChip(cuisine, Icons.local_dining, colors.primary),
                        if (type != null)
                          _buildChip(type, Icons.fastfood, colors.secondary),
                        if (price != null)
                          _buildChip(price, Icons.attach_money, colors.success),
                        if (distance != null)
                          _buildChip('$distance mi', Icons.location_on, colors.info),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  if (address != null) ...[
                    Semantics(
                      label: 'Address',
                      child: Row(
                        children: [
                          Icon(Icons.place, color: colors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              address,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Phone
                  if (phone != null) ...[
                    Semantics(
                      label: 'Phone',
                      child: Row(
                        children: [
                          Icon(Icons.phone, color: colors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(phone, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Website
                  if (website != null) ...[
                    Semantics(
                      label: 'Website',
                      child: Row(
                        children: [
                          Icon(Icons.language, color: colors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              website,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Hours
                  if (hours != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.access_time, color: colors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hours',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...hours.entries.map(
                                (e) => Text(
                                  '${e.key}: ${e.value}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .map((t) => Chip(
                                label: Text(t),
                                backgroundColor: colors.primary.withValues(alpha: 0.1),
                                side: BorderSide(
                                  color: colors.primary.withValues(alpha: 0.3),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action buttons
                  Text(
                    'Actions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'Open in Maps',
                    child: LiquidGlassButton(
                      icon: Icons.map,
                      label: 'Open in Maps',
                      onPressed: _openMaps,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Order on DoorDash',
                    child: LiquidGlassButton(
                      icon: Icons.delivery_dining,
                      label: 'Order on DoorDash',
                      onPressed: _openDoorDash,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (phone != null)
                    Semantics(
                      label: 'Call Restaurant',
                      child: LiquidGlassButton(
                        icon: Icons.phone,
                        label: 'Call Restaurant',
                        onPressed: _callRestaurant,
                      ),
                    ),
                  if (phone != null) const SizedBox(height: 8),
                  if (website != null)
                    Semantics(
                      label: 'Visit Website',
                      child: LiquidGlassButton(
                        icon: Icons.language,
                        label: 'Visit Website',
                        onPressed: _openWebsite,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
