import 'package:share_plus/share_plus.dart';
import 'package:app_links/app_links.dart';

/// Service for sharing winners and invite links.
class ShareService {
  static final _appLinks = AppLinks();

  /// Share the chosen restaurant via the system share sheet.
  static Future<void> shareWinner(String name, Map<String, dynamic>? details) async {
    final cuisine = details?['cuisine'] as String?;
    final type = details?['type'] as String?;
    final address = details?['address'] as String?;
    final price = details?['priceTier'] as String?;

    final buffer = StringBuffer();
    buffer.writeln('🍽️ IDK You Pick chose: $name');
    if (cuisine != null) buffer.writeln('Cuisine: $cuisine');
    if (type != null) buffer.writeln('Type: $type');
    if (price != null) buffer.writeln('Price: $price');
    if (address != null) buffer.writeln('Address: $address');
    buffer.writeln();
    buffer.writeln('Sent via IDK You Pick 📲');

    await SharePlus.instance.share(
      ShareParams(text: buffer.toString(), subject: "We're eating at $name!"),
    );
  }

  /// Generate an invite link that encodes current filter preferences.
  static String generateInviteLink({
    required Set<String> cuisines,
    required Set<String> types,
    required Set<String> priceTiers,
    double? maxDistance,
  }) {
    final params = <String, String>{
      if (cuisines.isNotEmpty) 'cuisines': cuisines.join(','),
      if (types.isNotEmpty) 'types': types.join(','),
      if (priceTiers.isNotEmpty) 'prices': priceTiers.join(','),
      if (maxDistance != null && maxDistance > 0) 'distance': maxDistance.toStringAsFixed(1),
    };

    final query = params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    return 'idkyoupick://invite${query.isNotEmpty ? '?$query' : ''}';
  }

  /// Share an invite link via the system share sheet.
  static Future<void> shareInviteLink(String url) async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Help me decide where to eat! Open this in IDK You Pick: $url',
        subject: 'Join me on IDK You Pick',
      ),
    );
  }

  /// Generate a kebab-case slug from a restaurant name.
  /// Lowercases, replaces spaces with hyphens, strips non-alphanumeric
  /// characters except hyphens.  If the generated slug already appears in
  /// [existingSlugs], appends -2, -3, etc. until a unique suffix is found.
  static String generateSlug(String name, {Iterable<String> existingSlugs = const []}) {
    var slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    if (slug.isEmpty) slug = 'restaurant';

    final base = slug;
    var counter = 2;
    while (existingSlugs.contains(slug)) {
      slug = '$base-$counter';
      counter++;
    }

    return slug;
  }

  /// Share a deep-link URL pointing to a specific restaurant.
  static Future<void> shareRestaurantLink(String slug) async {
    await SharePlus.instance.share(
      ShareParams(text: 'Check out this restaurant! idkyoupick://restaurant/$slug'),
    );
  }

  /// Listen for incoming app links (invite links, etc).
  static Stream<Uri> get incomingLinks => _appLinks.uriLinkStream;
}
