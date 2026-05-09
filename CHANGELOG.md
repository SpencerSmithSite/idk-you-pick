# Changelog — IDK You Pick

## [0.1.0] — 2026-05-08
### Setup
- Cloned repo and analyzed existing codebase
- Created PROJECT.md, TODO.md, CHANGELOG.md
- Documented current app state: 54 plain-string restaurants, dark gradient UI, two modes
- Established 5-phase roadmap with GitHub tracking

## [0.1.1] — 2026-05-08
### Phase 1: Data Overhaul (Part 1)
- **feat:** Transformed `restaurants.json` from plain strings to rich objects with cuisine, type, priceTier, tags[]
- Added 54 restaurants with full metadata (9 cuisine types, 4 type categories, 3 price tiers)
- Updated `lib/main.dart` `_loadRestaurants()` to support both old and new JSON formats (backward-compatible)
- Added `_restaurantDetails` list to hold enriched restaurant maps
- Verified: `flutter analyze` passes — no issues found
- Branch: `data/phase-1-data-overhaul`

---

## Format
### Date — Title
- What changed
- Commits: `abc123`
