import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/app_colors.dart';
import 'widgets/gradient_button.dart';
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

  Future<void> _openMaps(BuildContext context) async {
    final address = _get('address') ?? widget.restaurant['name'];
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address!)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showError(context, 'Could not open Maps');
    }
  }

  Future<void> _callRestaurant(BuildContext context) async {
    final phone = _get('phone');
    if (phone == null) {
      _showError(context, 'No phone number available');
      return;
    }
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showError(context, 'Could not place call');
    }
  }

  Future<void> _openWebsite(BuildContext context) async {
    final website = _get('website');
    if (website == null) {
      _showError(context, 'No website available');
      return;
    }
    final url = Uri.parse(website);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showError(context, 'Could not open website');
    }
  }

  Future<void> _openDoorDash(BuildContext context) async {
    final name = widget.restaurant['name'];
    final url = Uri.parse(
      'https://www.doordash.com/search/store/${Uri.encodeComponent(name)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showError(context, 'Could not open DoorDash');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
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
                    colors: isDark
                        ? AppColors.darkGradient
                        : AppColors.lightGradient,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
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
                        _buildChip(cuisine, Icons.local_dining, AppColors.teal),
                      if (type != null)
                        _buildChip(type, Icons.fastfood, AppColors.orange),
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
                        Icon(Icons.place, color: AppColors.teal, size: 20),
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
                        Icon(Icons.phone, color: AppColors.teal, size: 20),
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
                        Icon(Icons.language, color: AppColors.teal, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            website,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.teal,
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
                                backgroundColor:
                                    AppColors.teal.withOpacity(0.1),
                                side: BorderSide(
                                  color: AppColors.teal.withOpacity(0.3),
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
                  _ActionButton(
                    icon: Icons.map,
                    label: 'Open in Maps',
                    color: AppColors.teal,
                    onTap: () => _openMaps(context),
                  ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: Icons.delivery_dining,
                    label: 'Order on DoorDash',
                    color: AppColors.orange,
                    onTap: () => _openDoorDash(context),
                  ),
                  const SizedBox(height: 8),
                  if (phone != null)
                    _ActionButton(
                      icon: Icons.phone,
                      label: 'Call Restaurant',
                      color: Colors.grey[700]!,
                      onTap: () => _callRestaurant(context),
                    ),
                  if (phone != null) const SizedBox(height: 8),
                  if (website != null)
                    _ActionButton(
                      icon: Icons.language,
                      label: 'Visit Website',
                      color: Colors.grey[700]!,
                      onTap: () => _openWebsite(context),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: onTap,
      gradient: LinearGradient(
        colors: [color, color.withOpacity(0.8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
