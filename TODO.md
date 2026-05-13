# TODO — IDK You Pick

## Current Phase: 1 — Data Overhaul

### Done
- [x] 1.1 Recreate `restaurants.json` with rich metadata
- [x] 1.2 Add new fields: cuisine, type, priceTier, tags[]
- [x] 1.3 Update `main.dart` loader/parser
- [x] 1.4 Wire metadata into UI (random choice, head-to-head, winner views)
- [x] 1.5 Commit Phase 1 work

### Next Up
- [x] 1.6 Update PR #7 with latest changes

### Current Phase: 2 — Filter UI
- [ ] 2.1 Design filter UI layout (bottom sheet or settings page)
- [ ] 2.2 Add cuisine filter chips (multi-select)
- [ ] 2.3 Add type filter chips (multi-select)
- [ ] 2.4 Add priceTier filter slider or chips
- [ ] 2.5 Wire filters into random-choice generator
- [ ] 2.6 Wire filters into head-to-head pool
- [ ] 2.7 Persist filter state in SharedPreferences

### Blocked
- None

### Backlog
- Phase 3: Location Mode
- Phase 4: Dual Filters (already Phase 2, will renumber later)
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
