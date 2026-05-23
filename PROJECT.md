# IDK You Pick — Project Roadmap

## Overview
Restaurant decision app overhaul: modern UI, location-aware recommendations, and intelligent filtering.

## Phases

### Phase 1: Data Overhaul (Foundation) ✅
- [x] Restructure `restaurants.json` with cuisine/type/price/distance data
- [x] Update parser to handle new schema
- [x] Add cuisine mapping for all 54 restaurants
- [x] Add fallback data for new fields
- **Merged in PR #7**

### Phase 2: Modern UI/UX Redesign ✅
- [x] Glassmorphism cards with subtle blur/transparency
- [x] Smooth animations (page transitions, button presses, card reveals)
- [x] Modern font stack (replace Arial)
- [x] Refined color palette (teal/orange base, polished)
- [x] Responsive premium-mobile layout
- [x] Redesigned decision flow (random vs bracket vs near me)
- [x] Dark/light mode support
- **Merged in PR #8 / #17**

### Phase 3: Location + Nearby Mode ✅
- [x] Add `geolocator` package for GPS
- ~~Google Places API integration~~ *(de-scoped — on-device restaurant database preferred for privacy)*
- [x] New "Near Me" mode with distance radius
- [x] GPS denied fallback (zip code / manual city)
- ~~Show distance, ratings, photos from Places API~~ *(de-scoped)*
- **Merged in PR #9**

### Phase 4: Dual-Filter System ✅
- [x] Global Filters (Settings — permanent exclusions)
- [x] Session Filters (main screen — one-time exclusions)
- [x] Quick Filters (price, distance, type)
- [x] Cuisine: American, Italian, Mexican, Chinese, Japanese, Indian, Thai, Mediterranean, BBQ, etc.
- [x] Type: fast food, dine-in, takeout, delivery
- [x] Price tier: $, $$, $$$
- **Merged in PR #7 / #8**

### Phase 5: Restaurant Detail + Action Links ✅
- [x] Detail card with cuisine, price, distance, tags, hours
- [x] "Open Website" button → browser
- [x] "Open in Maps" button → native maps app
- [x] "Call" button (if phone available)
- [x] "Save to Favorites" toggle
- **Merged in PR #14**

## Status Log

| Date | Phase | Done | Blockers |
|------|-------|------|----------|
| 2026-05-08 | Initial | Cloned repo, analyzed codebase, approved plan | None |
| 2026-05-08 | Phase 1 | Data Overhaul — restaurants.json enriched, parser updated | None |
| 2026-05-08 | Phase 2 | Modern UI — Aurora Frost theme, glassmorphism cards | None |
| 2026-05-09 | Phase 3 | Location Mode — geolocator, distance filter, lat/lng data | None |
| 2026-05-10 | Phase 4 | Dual-Filter System — global + session filters, quick filters | None |
| 2026-05-10 | Phase 5 | Restaurant Detail + Action Links — maps, call, website, favorites | None |
| 2026-05-10 | Phase 6–19 | Features continued through Phase 19 (see CHANGELOG.md / TODO.md) | None |
| 2026-05-22 | Phase 20–22 | README refresh, widget tests, accessibility deep-dive, dependency maintenance | None |

## Notes
- Each phase gets a branch: `data/phase-{N}-{description}`
- PRs merged to `main` after review
- Main branch is protected — changes must go through PRs
- Apple Reminders sync via autonomous heartbeat
- Current version: **1.1.1+4**
