# TODO — IDK You Pick

## Done
- [x] Phase 1 — Data Overhaul (restaurant metadata, chips in UI)
- [x] Phase 2 — Filter UI (cuisine, type, priceTier chips, SharedPreferences persistence, indicator, empty state)
- [x] Phase 3 — Location Mode (geolocator, distance filter, lat/lng data, distance chips)
- [x] Phase 5 — History / Seen Tracking (PR #11, branch `data/phase-5-history-seen`, commit `39e61aa`)
- [x] Phase 6 — Share / Invite (PR #12, branch `data/phase-6-share-invite`, commit `3c28fed`)
- [x] Phase 7 — Onboarding / Tutorial (PR #13, branch `data/phase-7-onboarding`, commit `f4dd3d4`)
- [x] Phase 8 — Restaurant Detail + Favorites (branch `data/phase-8-restaurant-detail`, commit `af34346`)
- [x] Phase 9 — Favorites List Screen (branch `data/phase-9-favorites-list-v2`, commit `d8b12ee`)

PRs: #6 (project tracking), #7 (Phase 1), #8 (Phase 2), #9 (Phase 3), #11 (Phase 5), #12 (Phase 6), #13 (Phase 7), #14 (Phase 8), #15 (Phase 9)

---

## Phase 10 — Search & Sort ✅
- [x] Search screen with live text search across name, cuisine, type, tags
- [x] Sort by name, distance, price (low→high), cuisine, random
- [x] Respects active filters + distance
- [x] Tap-to-detail navigation, favorite indicator
- [x] Themed empty state, clear-search button

---

## Phase 11 — Aurora Frost Theme ✅
- [x] Create `lib/theme/` — color tokens, ThemeData provider, theme switching
- [x] Create `lib/widgets/` — GlassCard, GradientButton, GradientText, GlowOrb
- [x] Migrate hardcoded `Colors.*` to Aurora Frost semantic tokens (all screens)
- [x] Refactor `main.dart` — wrap History bottom sheet + Random Result in GlassCard
- [x] Refactor `filter_screen.dart` — wrap filters body in GlassCard
- [x] Refactor `restaurant_detail.dart` — wrap content in GlassCard
- [x] Refactor `search_screen.dart` — wrap sort bottom sheet in GlassCard
- [x] Refactor `settings.dart` — wrap settings list blocks in GlassCard
- [x] Refactor `favorites_list_screen.dart` — wrap list tiles in GlassCard
- [x] Refactor `main.dart` home screen with Aurora Frost styling
- [x] Screenshot light + dark mode for Captain

---

## Phase 12 — Testing, QA & Accessibility ✅
- [x] Unit tests for filter logic
- [x] Unit tests for location distance / Haversine formula
- [x] Unit tests for restaurant data parsing edge cases
- [x] Widget tests for onboarding flow
- [x] Widget tests for Settings save/restore cycle
- [x] CI `flutter analyze` + `flutter test` workflow
- [x] PR #17 updated and all checks green

---

## Phase 13 — Store Prep & Polish ✅ (PR #18)
### App Store Compliance
- [x] Dynamic Type / text scaling support (respect user's preferred text size)
- [x] Screen reader audit — Semantics() wrappers for key elements
- [x] Privacy Policy page (required for App Store with geolocation)
- [x] App Store description / keywords
- [x] Screenshots script (iPhone + iPad sizes)
- [x] Version bump in pubspec.yaml

### Remaining Widget Tests
- [x] Widget test for FilterScreen (chip selection, clear, apply)
- [x] Widget test for SearchScreen (query, sort, tap detail)
- [x] Widget test for FavoritesListScreen (add, remove, empty state)

---

## Phase 14 — Post-Launch Polish 🔄 (Current)
### Haptics & Micro-interactions
- [ ] Add haptic feedback on "Choose For Me" and "Help Me Decide" winner reveal
- [ ] Add haptic on filter chip tap, favorite toggle, history add/remove
- [ ] Subtle scroll physics / overscroll glow tuning

### App Store Review Prompt
- [ ] Integrate `in_app_review` package
- [ ] Show review prompt after 3+ successful "Choose For Me" picks
- [ ] Rate-limit: max once per 30 days, only if user hasn't rated

### Version & Build Info
- [ ] Add "About" tile in Settings showing version, build number, and Git commit
- [ ] Tap-to-copy support info for bug reports

### Performance & Polish
- [ ] Debounce search query (300ms) to reduce rebuilds
- [ ] Image asset placeholders / lazy loading for restaurant photos (if added later)
- [ ] Reduce unnecessary `setState` calls in main view rebuilds

---

## Legend
- [ ] = Not started  |  [-] = In progress  |  [x] = Done

### Workflow Notes
- **Main branch is protected** — changes must go through PRs
- **Branch naming:** `data/phase-{N}-{description}` or `data/feature-{name}`
- **Commit format:** `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`
- **After work session:** commit, push branch, open PR or update existing PR
- **Tick summary format:** "[IDK P{N}] {what got done} — branch: data/..."
