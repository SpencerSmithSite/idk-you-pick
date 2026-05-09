# IDK You Pick — Project Roadmap

## Overview
Restaurant decision app overhaul: modern UI, location-aware recommendations, and intelligent filtering.

## Phases

### Phase 1: Data Overhaul (Foundation)
- [ ] Restructure `restaurants.json` with cuisine/type/price/distance data
- [ ] Update parser to handle new schema
- [ ] Add cuisine mapping for all 54 restaurants
- [ ] Add fallback data for new fields
- [ ] **Commit hash: ___**

### Phase 2: Modern UI/UX Redesign
- [ ] Glassmorphism cards with subtle blur/transparency
- [ ] Smooth animations (page transitions, button presses, card reveals)
- [ ] Modern font stack (replace Arial)
- [ ] Refined color palette (teal/orange base, polished)
- [ ] Responsive premium-mobile layout
- [ ] Redesigned decision flow (random vs bracket vs near me)
- [ ] Dark/light mode support
- [ ] **Commit hash: ___**

### Phase 3: Location + Nearby Mode
- [ ] Add `geolocator` package for GPS
- [ ] Google Places API integration
- [ ] New "Near Me" mode with distance radius
- [ ] GPS denied fallback (zip code / manual city)
- [ ] Show distance, ratings, photos from Places API
- [ ] **Commit hash: ___**

### Phase 4: Dual-Filter System
- [ ] Global Filters (Settings — permanent exclusions)
- [ ] Session Filters (main screen — one-time exclusions)
- [ ] Quick Filters (price, distance, type)
- [ ] Cuisine: American, Italian, Mexican, Chinese, Japanese, Indian, Thai, Mediterranean, BBQ, etc.
- [ ] Type: fast food, dine-in, takeout, delivery
- [ ] Price tier: $, $$, $$$, $$$$
- [ ] **Commit hash: ___**

### Phase 5: Restaurant Detail + Action Links
- [ ] Detail card with photo, cuisine, price, rating, hours
- [ ] "Open Website" button → browser
- [ ] "Open in Maps" button → native maps app
- [ ] "Call" button (if phone available)
- [ ] "Save to Favorites" toggle
- [ ] **Commit hash: ___**

## Status Log

| Date | Phase | Done | Blockers |
|------|-------|------|----------|
| 2026-05-08 | Initial | Cloned repo, analyzed codebase, approved plan | None |

## Notes
- Each phase gets a branch: `phase/1-data`, `phase/2-ui`, etc.
- PRs merged to `main` after review
- Apple Reminders sync via autonomous heartbeat
