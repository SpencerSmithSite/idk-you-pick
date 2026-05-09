# TODO — IDK You Pick

## Done
- [x] Phase 1 — Data Overhaul (restaurant metadata, chips in UI)
- [x] Phase 2 — Filter UI (cuisine, type, priceTier chips, SharedPreferences persistence, indicator, empty state)
- [x] Phase 3 — Location Mode (geolocator, distance filter, lat/lng data, distance chips)

Prs: #6 (project tracking), #7 (Phase 1), #8 (Phase 2), #9 (Phase 3)

---

## Current Phase: 5 — History / Seen Tracking
- [x] 5.1 Persist tried-restaurant history in SharedPreferences (JSON)
- [x] 5.2 Load history on app start; exclude tried restaurants from pool when `_avoidRepeats` enabled
- [x] 5.3 Add `DateTime` map `_history` and `_avoidRepeats` toggle state
- [x] 5.4 Add "Tried it" button on random choice winner card (resets app after marking)
- [x] 5.5 Add "Tried it" button on head-to-head winner card
- [x] 5.6 Add history icon in AppBar to open bottom sheet listing tried restaurants
- [x] 5.7 Allow individual removal from history (X icon per item)
- [x] 5.8 Allow clearing all history from sheet
- [x] 5.9 QA: `flutter analyze` clean
- [ ] 5.10 Commit & push Phase 5
- [ ] 5.11 Open PR for Phase 5

### Next Phase: 6 — Share / Invite
- Phase 6: Share / Invite (share winner to Messages, generate invite link)

### Backlog
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
