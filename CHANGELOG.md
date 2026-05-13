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

*End of changelog.*
