# TODO — IDK You Pick

## Done
- [x] Phase 1 — Data Overhaul (restaurant metadata, chips in UI)
- [x] Phase 2 — Filter UI (cuisine, type, priceTier chips, SharedPreferences persistence, indicator, empty state)
- [x] Phase 3 — Location Mode (geolocator, distance filter, lat/lng data, distance chips)
- [x] Phase 5 — History / Seen Tracking (PR #11, branch `data/phase-5-history-seen`, commit `39e61aa`)
- [x] Phase 6 — Aurora Frost Design System (commit `409380b`, branch `data/phase-6-share-invite`)

PRs: #6 (project tracking), #7 (Phase 1), #8 (Phase 2), #9 (Phase 3), #11 (Phase 5)

---

## Current Phase: 6 — Share / Invite (in progress on same branch as theme)
- [x] 6.1 Share winner to Messages / clipboard
- [x] 6.2 Generate invite link
- [x] 6.3 Deep-link URL scheme (idkyoupick://invite)
- [x] 6.4 Handle incoming invite links (apply filters)

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
