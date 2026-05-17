# Design Decisions Log — IDK You Pick

Last updated: 2026-05-16

## Architecture
- **State management:** `StatefulWidget` + `ChangeNotifier` (ThemeProvider). No heavy state-management library—54 restaurants fit in memory.
- **Persistence:** `SharedPreferences` for all user data (favorites, filters, history, settings). JSON serialization via `jsonEncode`/`jsonDecode`.
- **Restaurant data:** Static JSON in `assets/restaurants.json`, loaded once at boot via root bundle.
- **Theme:** `ThemeProvider` wrapped in `ChangeNotifierProvider` in `main.dart`; MaterialApp's `themeMode` driven by provider.

## UI Design System Evolution
1. **V1 (original):** Dark gradient UI with solid cards.
2. **V2 (Aurora Frost):** Glassmorphism (blur + transparency) with gradient accents, teal + orange palette.
3. **V3 (Liquid Glass — current):** Apple WWDC 2025 Liquid Glass — heavy blur (σ=20–45), near-transparent surfaces (α=0.06–0.20), white edge refraction highlights, diffused shadows. Replaced GlowOrbs and GradientButtons with dedicated `LiquidGlass*` widgets.

## Why Liquid Glass instead of Aurora Frost glass-cards?
- Aurora Frost was a DIY glass effect (`BackdropFilter` + `Opacity`). Liquid Glass uses the platform-accurate style from iOS 26 that users will expect.
- Liquid Glass is simpler to maintain: one core widget (`LiquidGlass`) parameterized by blur and opacity; all other Liquid Glass widgets are thin wrappers.
- Edge refraction highlight + diffused shadow are built in; no need for manual `BoxShadow` tweaking.

## Package Philosophy
- **Conservative:** Only add a package if the benefit outweighs the binary-size and maintenance cost.
- **Geolocation:** `geolocator` + `geocoding` for location services; pinned to v13/v3 to avoid breaking changes.
- **Sharing:** `share_plus` for system share sheet; `app_links` for deep-link invite parsing.
- **No HTTP client:** Restaurant data is static JSON; no server needed.
- **No analytics or crash reporting:** Not required for MVP; can add later via `firebase_analytics` if needed.

## Testing Strategy
- **Unit tests** for pure logic: `FilterEngine`, `LocationService` Haversine, `ReviewService` state machine, `RestaurantData` JSON parsing.
- **Widget tests** for complex screens: `Onboarding`, `FilterScreen`, `SearchScreen`, `FavoritesListScreen`.
- **CI:** `flutter analyze` (zero issues) + `flutter test` (all pass) + `flutter build ios --simulator` (no build regressions).

## Branch Hygiene
- Branch names: `data/phase-{N}-{description}` or `fix/issue-{N}-{description}`.
- All changes go through PRs; `main` is protected.
- After merge: local feature branches are renamed to `z-archive/{name}` (kept for reflog) or deleted if merged cleanly.

## Versioning
- `pubspec.yaml`: `MAJOR.MINOR.PATCH+BUILD_NUMBER`.
- `CHANGELOG.md`: entries per phase/feature, with QA notes (`flutter analyze`, `flutter test`, `flutter build ios`).
- Tags: none yet; rely on GitHub releases for version milestones.
