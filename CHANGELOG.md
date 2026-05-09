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

## Format
### Date — Title
- What changed
- Commits: `abc123`
