import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/app_colors.dart';
import 'favorites_service.dart';

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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
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
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
                tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                  child: Icon(
                    Icons.restaurant,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (cuisine != null)
                        _buildChip(cuisine, Icons.local_dining, colors.primary),
                      if (type != null)
                        _buildChip(type, Icons.fastfood, colors.secondary),
                      if (price != null)
                        _buildChip(price, Icons.attach_money, Colors.green),
                      if (distance != null)
                        _buildChip('$distance mi', Icons.location_on, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address
                  if (address != null) ...[
                    Row(
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
                    const SizedBox(height: 12),
                  ],

                  // Phone
                  if (phone != null) ...[
                    Row(
                      children: [
                        Icon(Icons.phone, color: colors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(phone, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Website
                  if (website != null) ...[
                    Row(
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
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.map,
                    label: 'Open in Maps',
                    gradient: colors.primaryGradient,
                    onTap: _openMaps,
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    icon: Icons.delivery_dining,
                    label: 'Order on DoorDash',
                    gradient: colors.secondaryGradient,
                    onTap: _openDoorDash,
                  ),
                  const SizedBox(height: 8),
                  if (phone != null)
                    _buildActionButton(
                      icon: Icons.phone,
                      label: 'Call Restaurant',
                      gradient: [Colors.grey[700]!, Colors.grey[600]!],
                      onTap: _callRestaurant,
                    ),
                  if (phone != null) const SizedBox(height: 8),
                  if (website != null)
                    _buildActionButton(
                      icon: Icons.language,
                      label: 'Visit Website',
                      gradient: [Colors.grey[700]!, Colors.grey[600]!],
                      onTap: _openWebsite,
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
