## [0.4.0] — 2026-05-13
### Phase 14: Post-Launch Polish (Part 1)
- **feat:** Added `lib/services/haptics_service.dart` with 5 semantic flavors (light, medium, heavy, selection, success)
- **feat:** Wired haptic feedback into all major interactions:
  - Winner reveal (Choose For Me, Help Me Decide, bracket picks)
  - Filter chip tap, Apply button, Clear filters
  - Favorite toggle (RestaurantDetail) and remove (FavoritesList swipe)
  - Tried-it, Start Over, Reset, external-link share taps
- **test:** Added `test/unit/haptics_service_test.dart` (5 tests)
- **ci:** `flutter analyze` clean, `flutter test` 46/46 passing, iOS sim build success
- Branch: `data/phase-14-post-launch-polish`
- PR: #19

---

# Changelog — IDK You Pick

## [0.1.0] — 2026-05-08
### Setup
- Cloned repo and analyzed existing codebase
- Created PROJECT.md, TODO.md, CHANGELOG.md
- Documented current app state: 54 plain-string restaurants, dark gradient UI, two modes
- Established 5-phase roadmap with GitHub tracking

## [0.1.1] — 2026-05-08
### Phase 1: Data Overhaul
- **feat:** Transformed `restaurants.json` from plain strings to rich objects with cuisine, type, priceTier, tags[]
- Added 54 restaurants with full metadata (9 cuisine types, 4 type categories, 3 price tiers)
- Updated `lib/main.dart` `_loadRestaurants()` to support both old and new JSON formats (backward-compatible)
- Added `_restaurantDetails` list to hold enriched restaurant maps
- **feat:** Wired metadata into UI — cuisine/type/price/tags chips shown on random choice, head-to-head options, and winner views
- Verified: `flutter analyze` passes — no new issues introduced
- Branch: `data/phase-1-data-overhaul`

---

## [0.1.2] — 2026-05-08
### Phase 2: Filter UI
- **feat:** Added `lib/filter_screen.dart` with multi-select chip groups for Cuisine, Type, and Price Tier
- **feat:** Wired `_filteredPool` getter into `lib/main.dart` — applies preferences + active filters to random choice and head-to-head pools
- **feat:** Filter state persisted in SharedPreferences (`filter_cuisines`, `filter_types`, `filter_prices`)
- **feat:** Added filter icon to AppBar; settings icon moved alongside
- **feat:** Dynamic filter pool rebuilds when user returns from FilterScreen
- **fix:** Resolved `use_build_context_synchronously` lint in filter_screen.dart by capturing `Navigator.of(context)` before async gaps
- Verified: `flutter analyze` — no NEW issues introduced (11 total, same 6 pre-existing dataconnect errors + 2 pre-existing lints + 1 asset warning)
- Branch: `data/phase-2-filter-ui`

---

## [0.1.3] — 2026-05-08
### Phase 2: Filter UI (Completion)
- **feat:** Added active filter indicator dot on filter icon when any filter is applied
- **feat:** "No restaurants match your filters" empty state with clear-filters button on both random choice and head-to-head views
- **fix:** Replaced `_restaurants.remove(loser)` in `_pickWinner()` with bracket progression using `_filteredPool` — prevents accidentally deleting a restaurant permanently in head-to-head mode
- **fix:** Consolidated two duplicate "no results" views into a single reusable widget; corrected `setState()` to reset both `_helpMeDecideMode` and `chosenRestaurant`/`_optionA`/`_optionB`
- Verified: `flutter analyze` — no NEW issues introduced (10 total: 7 pre-existing dataconnect errors + 1 pre-existing lint + 1 asset warning)
- Branch: `data/phase-2-filter-ui`

---

## [0.1.4] — 2026-05-09
### Phase 3: Location Mode
- **feat:** Added `geolocator` & `geocoding` dependencies; updated `pubspec.yaml`
- **feat:** Added deterministic lat/lng coordinates to all 54 restaurants in `assets/restaurants.json`
- **feat:** Created `lib/location_service.dart` — permission handling, position caching, Haversine distance in miles
- **feat:** Added iOS location usage strings to `Info.plist`
- **feat:** `_filteredPool` now respects distance filter (`_maxDistanceMiles`) when user location available
- **feat:** Added distance chip (`_buildDistanceMeta`) on random choice and head-to-head cards
- **feat:** Added distance slider (1–25 mi) to `FilterScreen` with persistence via SharedPreferences
- **fix:** Wrapped `_filteredPool` shuffle in `List.from()` to avoid mutating the underlying list
- **fix:** `FilterScreen` now accepts `maxDistance` and `onDistanceChanged` callbacks
- Verified: `flutter analyze` passes (1 deprecated `desiredAccuracy` info on `location_service.dart`)
- Branch: `data/phase-3-location-mode`

---

## [0.1.5] — 2026-05-09
### Phase 4: Action Links
- **feat:** Added `url_launcher` dependency and import to `lib/main.dart`
- **feat:** Added `phone` and `website` fields to `assets/restaurants.json` (scaffold for future enrichment)
- **feat:** Implemented URL helpers: `_openMaps`, `_openDoorDash`, `_callRestaurant`, `_openWebsite`
- **feat:** Added `_buildActionButtons` widget — conditionally shows Maps, DoorDash, Call, Website buttons
- **feat:** Wired action buttons into `_buildRandomChoiceView` and winner section of `_buildHelpMeDecideView`
- **feat:** Colors match existing palette: teal (Maps), orange (DoorDash), dark gray (Call / Website)
- Verified: `flutter analyze` — no NEW issues introduced (11 total, same pre-existing)
- Branch: `data/phase-4-action-links`

---

## [0.1.6] — 2026-05-09
### Phase 5: History / Seen Tracking
- **feat:** Added `_history` (Map<String, DateTime>) and `_avoidRepeats` (bool) state fields in `_MyHomePageState`
- **feat:** `_loadHistory()` — restores `_history` from SharedPreferences JSON string on app start
- **feat:** `_saveHistory()` — persists `_history` as ISO-8601 encoded JSON keyed by `restaurant_history`; also saves `_avoidRepeats`
- **feat:** Modified `_filteredPool` getter — when `_avoidRepeats` is on and `_history` is non-empty, excludes tried restaurants from random choice and head-to-head pools
- **feat:** `_markTried(name)` — adds restaurant to `_history` with current timestamp, persists, and returns to home view
- **feat:** `_showHistorySheet()` — opens a bottom sheet listing all tried restaurants sorted newest→oldest, with mm/dd/yyyy subtitle and an X icon to remove individual items
- **feat:** `_removeFromHistory(name)` — removes a single restaurant from history and refreshes persistence
- **feat:** `_clearHistory()` — wipes entire history and refreshes persistence
- **feat:** Added history icon (`Icons.history`) to AppBar actions, taps to open `_showHistorySheet()`
- **feat:** Added "Tried it" button (dark gray, `Icons.check_circle`) on random choice winner card
- **feat:** Added "Tried it" button on head-to-head winner card — both reset to home after marking
- **docs:** Updated `CHANGELOG.md` with [0.1.6] entry
- **docs:** Updated `TODO.md` — Phase 5 items all `[x]`, added Phase 6 header
- Verified: `flutter analyze` — no NEW issues introduced (11 total: all pre-existing)
- Branch: `data/phase-5-history-seen`

---

## [0.1.7] — 2026-05-09
### Phase 6: Share / Invite
- **feat:** Added `share_plus` and `app_links` dependencies to `pubspec.yaml`
- **feat:** Created `lib/share_service.dart` — `ShareService` class with `shareWinner()`, `generateInviteLink()`, `shareInviteLink()`, and `incomingLinks` stream
- **feat:** `shareWinner()` formats restaurant details (name, cuisine, type, price, address) into a shareable message via system share sheet
- **feat:** `generateInviteLink()` encodes active filters (cuisines, types, price tiers, max distance) into `idkyoupick://invite?...` deep-link URL
- **feat:** Wired share icon into AppBar actions (`Icons.share`) that opens `_showShareSheet()` bottom sheet
- **feat:** `_showShareSheet()` offers two options: "Share winner" (when restaurant chosen) and "Invite link" (always available)
- **feat:** Added "Share Winner" `GradientButton` on both random-choice winner card and head-to-head winner card
- **feat:** Added `CFBundleURLTypes` to `ios/Runner/Info.plist` registering `idkyoupick://` custom URL scheme
- **feat:** Subscribed to `ShareService.incomingLinks` in `initState()` and added `dispose()` to cancel subscription
- **feat:** `_handleIncomingLink(Uri)` parses invite-link query parameters and applies them to `_activeCuisines`, `_activeTypes`, `_activePriceTiers`, and `_maxDistanceMiles`
- **QA:** `flutter analyze` — zero new errors (all remaining issues are pre-existing: dataconnect stubs, deprecated geolocator, asset dir warning)
- **QA:** `flutter build ios --simulator` — builds successfully
- Branch: `data/phase-6-share-invite`

---

## [0.1.8] — 2026-05-10
### Phase 7: Onboarding / Tutorial
- **feat:** Created `lib/onboarding.dart` — 4-slide PageView walkthrough (welcome, random pick, head-to-head, settings)
  - themed dot indicators (animated width), gradient "Get Started" button, Skip option on non-final slides
  - `OnboardingService` with SharedPreferences key `onboarding_complete`; `resetOnboarding()` wired into Settings tile
- **feat:** Created `lib/how_it_works.dart` — first-run "How It Works" overlay on main screen
  - Dark modal with 4 bullet instructions, persists dismissal via `has_seen_how_it_works` flag
- **feat:** Created `lib/demo_service.dart` — `DemoService.generateFakeRestaurants()` generates 6 synthetic spots with lat/lng
  - toggled via Settings tile `DemoModeTile` with `demo_mode_enabled` flag
  - `_loadRestaurants(demoMode:)` uses demo data when enabled
- **feat:** Updated `lib/main.dart` — `MyApp` is now `StatefulWidget` with `FutureBuilder<bool>` onboarding gate
  - `_initializeApp()` passes `demoMode` into `_loadRestaurants()`
  - `_hasSeenHowItWorks` state + `_dismissHowItWorks()` persistence
  - `_buildDefaultView()` wraps `HowItWorksOverlay` in a `Stack`
- **feat:** Updated `lib/settings.dart` — added "Restart Onboarding" and "Demo Mode" tiles
- **QA:** `flutter analyze` — zero new Dart errors (pre-existing issues only)
- **QA:** `flutter test` — passes
- **QA:** `flutter build ios --simulator` — builds successfully
- Branch: `data/phase-7-onboarding`, commit `f4dd3d4`

---

## [0.1.9] — 2026-05-10
### Phase 8: Restaurant Detail Screen
- **feat:** Created `lib/restaurant_detail.dart` — full-screen detail view with `CustomScrollView` + `SliverAppBar`
- **feat:** Displays cuisine, type, price tier, distance chips, address, phone, website, tags
- **feat:** Action buttons: Maps, DoorDash, Call, Website (consistent with existing palette)
- **feat:** Favorite toggle with heart icon in AppBar; persisted via `FavoritesService` (SharedPreferences)
- **feat:** "View Details" button added to random choice winner and head-to-head winner views
- **feat:** "View Details" link added to each head-to-head option card for quick preview before picking
- **feat:** Created `lib/favorites_service.dart` — `addFavorite`, `removeFavorite`, `isFavorite`, `toggleFavorite`
- Verified: `flutter analyze` passes — no NEW issues introduced
- Branch: `data/phase-8-restaurant-detail`

---

## [0.2.0] — 2026-05-10
### Phase 9: Favorites List Screen
- **feat:** Created `lib/favorites_list_screen.dart` — dedicated favorites list view
  - Themed list tiles with cuisine/type/price/distance chips, swipe-to-remove via `Dismissible`
  - Empty state with Aurora Frost gradient illustration and "Start favoriting!" prompt
  - Tap-to-detail navigation via `RestaurantDetailScreen`
- **feat:** Heart icon added to `AppBar` actions in `main.dart`; opens `FavoritesListScreen`
- **feat:** `FavoritesListScreen` uses `FavoritesService` to load persisted favorites and sync in real-time
- Verified: `flutter analyze` passes — no NEW issues introduced
- Branch: `data/phase-9-favorites-list-v2`, commit `d8b12ee`

---

## [0.2.1] — 2026-05-10
### Phase 10: Search & Sort Screen
- **feat:** Created `lib/search_screen.dart` — live text search across name, cuisine, type, and tags
- **feat:** Sort bottom sheet with 5 options: name A→Z, distance nearest, price low→high, cuisine, random
- **feat:** Respects active filters + distance; shows favorite indicator on results
- **feat:** Tap-to-detail navigation via `RestaurantDetailScreen`
- **feat:** Themed empty state with "No matches" message and clear-search button
- **feat:** Added search icon (`Icons.search`) to `AppBar` actions in `main.dart`
- **feat:** Added `distanceBetween` alias in `location_service.dart` for sorting by distance
- **QA:** `flutter analyze` — zero new errors (pre-existing issues only)
- **QA:** `flutter build ios --simulator` — builds successfully
- Branch: `data/phase-10-search-sort`, commit `2d3abc5`

---

## [0.2.2] — 2026-05-11
### Bug Fixes: Location Opt-In, AppBar Title, Empty Pool Messages
- **fix:** `lib/main.dart` `_initializeApp()` — checks `Geolocator.checkPermission()` *before* calling `determinePosition()` to avoid requesting permission on every cold launch; silently sets `_useLocation = false` and persists to SharedPreferences (`use_location`) if denied or deniedForever
- **fix:** `_filteredPool` now correctly gated by `_useLocation == true` AND `_userPosition != null`; custom restaurants with `null` lat/lng are always retained (not subject to distance filtering)
- **fix:** `_getEmptyPoolMessage()` distinguishes three causes: all restaurants disabled, no restaurants within distance, and filters too restrictive
- **fix:** `lib/settings.dart` `Use My Location` toggle persists to SharedPreferences; `onLocationChanged` callback wired in `main.dart` to clear `_userPosition` when disabled and re-acquire when enabled
- **fix:** `FilterScreen` hides distance slider and shows italic "Enable location to filter by distance" when `useLocation == false`
- **fix:** `SearchScreen` distance sort/filter respects `useLocation` state and retains null-coord custom restaurants
- **fix:** AppBar title truncation in `main.dart`, `settings.dart`, `filter_screen.dart` resolved with `FittedBox(fit: BoxFit.scaleDown)` + `fontSize: 20`
- **QA:** `flutter analyze` — zero new errors
- **QA:** `flutter test` — 13/13 passing
- **QA:** `flutter build ios --simulator` — builds successfully
- Branch: `data/aurora-frost-theme`

## [0.3.3] — 2026-05-12
### CI Fix: unused_import lint
- **test:** Removed unused `import 'package:rest_chooser/settings.dart';` from `test/unit/settings_service_test.dart`
- **QA:** `flutter analyze` — zero issues (was failing CI due to unused_import warning treated as error)
- **QA:** `flutter test` — 30/30 passing
- Branch: `data/aurora-frost-theme`, commit `e391beb`, PR #17 updated

## [0.3.2] — 2026-05-12
### Phase 12 Complete: CI Enhancement & Final QA
- **ci:** Enhanced `.github/workflows/flutter-test.yml` with `flutter analyze` lint gate and macOS `build-ios --simulator --no-codesign` job to prevent iOS build regressions
- **docs(TODO):** Marked Phases 10, 11, and 12 as complete; promoted Phase 12 remaining items (Settings widget tests, text scaling, screen reader audit) into Phase 13: Store Prep & Polish
- **chore:** Updated branch `data/aurora-frost-theme` commit `5f2ce52`; PR #17 updated

## [0.3.1] — 2026-05-12
### Phase 12: Testing, QA & Accessibility (Incremental)
- **test(unit):** Added `test/unit/restaurant_data_test.dart` — validates all 54 JSON records: required-field presence, unique non-empty names, lat/lng within US bounds, allowed cuisine/type/priceTier values, non-empty string tag lists, optional website/phone null-or-valid checks
- **test(widget):** Added `test/widget/onboarding_test.dart` — 4-slide flow coverage: title/icon rendering, Next/Skip navigation, dot-indicator state, onComplete callback on final slide and via Skip
- **test(unit):** Added `test/unit/settings_service_test.dart` — SharedPreferences round-trip for restaurant bools, `use_location` flag, and `customRestaurants` list
- **QA:** `flutter test` — 30/30 passing (7 filter + 5 Haversine + 1 widget + 9 restaurant data + 3 settings service + 5 onboarding)
- **QA:** `flutter analyze` — zero issues
- **QA:** `flutter build ios --simulator` — builds successfully
- **docs(TODO):** Marked data-parsing tests and onboarding widget tests done under Phase 12
- **chore:** Synced TODO.md phase ordering (Phase 10, 11, 12)
- Branch: `data/aurora-frost-theme`, commit `d1b20bc`, PR #17 updated

## [0.3.0] — 2026-05-11 (proactive)
### Aurora Frost Theme Foundation
- **feat:** Aurora Frost design system foundation — light/dark mode, glassmorphism, gradient buttons, glow orbs, theme tokens
- **feat:** `lib/theme/app_colors.dart` — color tokens for light/dark (surface, primary, secondary, text, chip, shadow, danger)
- **feat:** `lib/theme/app_theme.dart` — `ThemeData` definitions for light + dark modes (ColorScheme, AppBar, chips, slider, checkbox, input)
- **feat:** `lib/theme/theme_provider.dart` — `ChangeNotifier` for theme mode switching with SharedPreferences persistence (`app_theme_mode`)
- **feat:** `lib/widgets/glass_card.dart` — reusable glassmorphism card widget (opacity + border + shadow)
- **feat:** `lib/widgets/gradient_button.dart` — reusable gradient pill button with primary/secondary variants
- **feat:** `lib/widgets/gradient_text.dart` — reusable `ShaderMask` gradient text widget
- **feat:** `lib/widgets/glow_orb.dart` — reusable radial glow orbs for ambient background decoration
- **feat:** Settings screen `Appearance` row with System / Light / Dark choice chips (fully functional)
- **fix:** Replaced deprecated `Switch.activeColor` with `activeTrackColor` + `WidgetStateProperty` thumb color in Settings (2 instances)
- **fix:** Fixed `use_build_context_synchronously` lint in Settings `onPressed` save handler
- **QA:** `flutter analyze` — zero issues across all 15 Dart source files
- **QA:** `flutter build ios --simulator` — builds successfully
- Branch: `data/aurora-frost-theme`, PR #17 opened

---

## [0.3.4] — 2026-05-13
### Phase 13: Store Prep & Polish (First pass)
- **feat(a11y):** Dynamic Type support — clamped `textScaler` in `MaterialApp` via `MediaQuery` (0.8–1.4x) to respect accessibility while preventing layout breakage
- **feat(a11y):** Semantics wrappers on main action buttons: "Choose For Me" & "Help Me Decide" with descriptive labels for VoiceOver/TalkBack
- **feat(legal):** New `lib/privacy_policy.dart` — Aurora Frost themed Privacy Policy screen with on-device data disclosure, location policy, third-party services list
- **feat(legal):** Settings screen now links to Privacy Policy via a new GlassCard row (App Store compliance for geolocation apps)
- **test:** 11 new widget tests added:
  - `test/widget/filter_test.dart` — 4 tests (render, chip tap, clear-all, distance toggle)
  - `test/widget/search_test.dart` — 5 tests (render, sort, query filter, empty state, clear btn)
  - `test/widget/favorites_test.dart` — 2 tests (builds, themed container)
  - Total: **30 → 41 tests**, all passing
- **chore:** Bump version to `1.0.1+2` in `pubspec.yaml`
- **QA:** `flutter analyze` — zero issues
- **QA:** `flutter test` — 41/41 pass
- **QA:** `flutter build ios --simulator` — builds successfully
- Branch: `data/phase-13-store-prep`

---

## [0.3.5] — 2026-05-13
### Phase 13: Store Prep & Polish (Second pass)
- **chore:** Add `metadata/app_store_description.txt` — full App Store listing copy (description, keywords, categories, support/marketing URLs)
- **chore:** Add `scripts/take_screenshots.sh` — automated iOS Simulator screenshot pipeline for 6.7in, 6.1in, 5.5in devices; light + dark captures each
- **docs:** Update README to reference new scripts directory for building App Store graphics
- **chore:** Update `TODO.md` — mark App Store description and screenshot script complete
- **QA:** `flutter analyze` — zero issues
- **QA:** `flutter test` — 41/41 pass
- Branch: `data/phase-13-store-prep`

---

*End of changelog.*
