# TODO — IDK You Pick

## Done
- [x] Phase 1 — Data Overhaul (restaurant metadata, chips in UI)
- [x] Phase 2 — Filter UI (cuisine, type, priceTier chips, SharedPreferences persistence, indicator, empty state)
- [x] Phase 3 — Location Mode (geolocator, distance filter, lat/lng data, distance chips)

Prs: #6 (project tracking), #7 (Phase 1), #8 (Phase 2), #9 (Phase 3)

---

## Current Phase: 4 — Action Links
- [-] 4.1 Add `url_launcher` dependency to `pubspec.yaml`
- [-] 4.2 Generate Google Maps URL for each restaurant (lat/lng based)
- [-] 4.3 Generate DoorDash search URL (or fallback web search)
- [-] 4.4 Add action buttons / chips on restaurant detail / winner view
  - Open in Maps
  - Search on DoorDash
  - Call restaurant (if phone available)
  - Visit website (if URL available)
- [-] 4.5 Add action buttons on random choice card (Maps, DoorDash)
- [-] 4.6 Add action buttons on head-to-head winner card
- [-] 4.7 QA: `flutter analyze` clean
- [ ] 4.8 Commit & push Phase 4
- [ ] 4.9 Open PR for Phase 4

### Blocked
- None

### Backlog
- Phase 5: History / Seen Tracking (mark restaurants as tried, avoid repeats)
- Phase 6: Share / Invite (share winner to Messages, generate invite link)
- Phase 7: Onboarding / tutorial for first-time user

---

## Legend
- [ ] = Not started  |  [-] = In progress  |  [x] = Done

### Workflow Notes
- **Main branch is protected** — changes must go through PRs
- **Branch naming:** `data/phase-{N}-{description}` or `data/feature-{name}`
- **Commit format:** `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`
- **After work session:** commit, push branch, open PR or update existing PR
- **Tick summary format:** "[IDK P{N}] {what got done} — branch: data/..."
