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

## Phase 14 — Post-Launch Polish ✅
### Haptics & Micro-interactions ✅
- [x] Add haptic feedback on "Choose For Me" and "Help Me Decide" winner reveal
- [x] Add haptic on filter chip tap, favorite toggle, history add/remove
- [x] Review prompt integration (in_app_review package, ReviewService with pick-count threshold, 30-day cooldown, rated flag)
- [x] Subtle scroll physics — `_AppScrollBehavior` with `BouncingScrollPhysics` on both iOS & Android, no overscroll glow
- [x] Reduce unnecessary `setState` — shuffle pool outside `setState` in `_chooseRandom()` and `_startHeadToHead()`

### App Store Review Prompt
- [x] Integrate `in_app_review` package
- [x] Show review prompt after 3+ successful "Choose For Me" picks
- [x] Rate-limit: max once per 30 days, only if user hasn't rated

### Version & Build Info ✅
- [x] Add "About" tile in Settings showing version, build number, and Git commit
- [x] Tap-to-copy support info for bug reports

### Performance & Polish ✅
- [x] Debounce search query (300ms) to reduce rebuilds
- [x] Reduce unnecessary `setState` calls in main view rebuilds

---

## Phase 15 — Next Feature ✅ (Completed)
_Placeholder—work superseded by Phase 17 Push Notifications._

---

## Phase 16 — Price Bracket Battle ✅ (PR #40)
- [x] New "Price Bracket Battle" option on main screen (third main button)
- [x] Tier selector screen with `$`, `$$`, `$$$` Aurora Frost themed chips
- [x] Reuses existing Help Me Decide bracket UI and `_pickWinner` logic
- [x] Temporarily applies price filter, starts bracket, restores filters after
- [x] Haptic feedback on tier tap and battle start
- [x] New reusable `GradientButton` widget in `lib/widgets/`
- [x] Generic `Route<T>` fix for `_fadeSlideRoute`

---

## Phase 17 — Push Notifications: Lunchtime Suggestions ✅ (PR #42)
- [x] Add `flutter_local_notifications`, `timezone`, `workmanager` to `pubspec.yaml`
- [x] Create `lib/services/notification_service.dart` — init, permissions, schedule, cancel, deep-link handling
- [x] Create `lib/services/lunch_suggestion_service.dart` — selection logic, filters, distance, 7-day history
- [x] Add toggle + privacy subtitle + permission denied banner to `lib/screens/settings.dart`
- [x] Wire notification tap handler and cold-start deep-link in `lib/main.dart`
- [x] Unit/widget test: `test/unit/lunch_suggestion_service_test.dart`
- [x] `flutter analyze` clean, `flutter test` passing, `flutter build ios --simulator` success
- [x] PR created and merged

---

## Phase 18 — Data Export / Import ✅ (PR #45)
- [x] Add `file_picker` dependency to `pubspec.yaml`
- [x] Create `lib/services/data_export_service.dart` — `DataExportService.exportUserData()` with schemaVersion 1
- [x] Create `lib/services/data_import_service.dart` — `DataImportService.importUserData()` with validation, `ImportSummary`, `ImportException`
- [x] Add Data Management section to Settings with Export (share_plus) and Import (file picker + confirmation dialog + snackbar error) tiles
- [x] Unit tests: `test/unit/data_export_service_test.dart` (3 tests), `test/unit/data_import_service_test.dart` (5 tests)
- [x] `flutter analyze` clean, `flutter test` 86/86 passing, `flutter build ios --simulator` success
- [x] PR created and merged

---

## Phase 19 — Complete Restaurant Deep Links ✅
- [x] Android deep-link intent-filter for `idkyoupick` scheme
- [x] Cold-start link handling via `ShareService.getInitialLink()` in `_initializeApp()`
- [x] `addPostFrameCallback` guard in `_handleIncomingLink` for safe `BuildContext` usage during init
- [x] Unit tests: `test/unit/deep_link_test.dart` (`getInitialLink`, slug parsing, query params, unknown scheme)
- [x] `flutter analyze` clean, `flutter test` passing

---

---

## Phase 20 — README & Docs Refresh (In Progress)
- [x] **Update README** — correct tech stack, add Phase 1–19 feature list, accurate description
- [x] **Update PROJECT.md** — mark Phase 1–5 complete, remove Phase 3 Google Places API scope (not implemented)
- [ ] **Prune stale branches** — archive or delete merged branches from `data/phase-*` and `z-archive/*`
- [-] **Dependency bumps** (batch) — `in_app_review`, `flutter_launcher_icons`, `flutter_native_splash`, `shared_preferences`
- [ ] **Investigate OpenCode** — intermittent hangs during `flutter pub get`; logs show idle for minutes despite unchanged tree. Need reproduction and config audit.

---

## Legend
- [ ] = Not started  |  [-] = In progress  |  [x] = Done

### Workflow Notes
- **Main branch is protected** — changes must go through PRs
- **Branch naming:** `data/phase-{N}-{description}` or `data/feature-{name}`
- **Commit format:** `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`
- **After work session:** commit, push branch, open PR or update existing PR
- **Tick summary format:** "[IDK P{N}] {what got done} — branch: data/..."
