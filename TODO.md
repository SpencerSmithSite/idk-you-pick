# TODO — IDK You Pick

## Current Phase: 1 — Data Overhaul

### Done
- [x] 1.1 Recreate `restaurants.json` with rich metadata
- [x] 1.2 Add new fields: cuisine, type, priceTier, tags[]
- [x] 1.3 Update `main.dart` loader/parser
- [x] 1.4 Wire metadata into UI (random choice, head-to-head, winner views)
- [x] 1.5 Commit Phase 1 work
- [x] 1.6 Update PR #7 with latest changes

### Current Phase: 2 — Filter UI
- [x] 2.1 Design filter UI layout (bottom sheet or settings page)
- [x] 2.2 Add cuisine filter chips (multi-select)
- [x] 2.3 Add type filter chips (multi-select)
- [x] 2.4 Add priceTier filter chips
- [x] 2.5 Wire filters into random-choice generator
- [x] 2.6 Wire filters into head-to-head pool
- [x] 2.7 Persist filter state in SharedPreferences
- [ ] 2.8 Add filter indicator on home screen when filters active
- [ ] 2.9 Show "no results" state when all filters deselect everything
- [ ] 2.10 QA: verify flutter analyze passes (no new issues)
- [ ] 2.11 Commit & push Phase 2

### Blocked
- None

### Backlog
- Phase 3: Location Mode
- Phase 5: Action Links

---

## Legend
- [ ] = Not started  |  [-] = In progress  |  [x] = Done

### Workflow Notes
- **Main branch is protected** — changes must go through PRs
- **Branch naming:** `data/phase-{N}-{description}` or `data/feature-{name}`
- **Commit format:** `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`
- **After work session:** commit, push branch, open PR or update existing PR
- **Tick summary format:** "[IDK P{N}] {what got done} — branch: data/..."
