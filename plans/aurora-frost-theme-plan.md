# Aurora Frost Design System — Implementation Plan

## Overview
Migrate the IDK You Pick Flutter app from its current hardcoded teal/orange design to the **Aurora Frost** design system with full light/dark mode support, glassmorphism, and transparency.

---

## Design Philosophy
- **Light mode**: Soft white/pale blue base, teal primary, coral secondary, frosted glass surfaces
- **Dark mode**: Deep navy/charcoal base, same teal/coral accents at higher saturation, darker glass surfaces
- **Glassmorphism**: Semi-transparent surfaces with blur, subtle 1px borders, radial glow accents
- **Sparks of color**: Gradients on primary actions, accent chips, and winner text. Rest of the UI stays neutral/minimal.

---

## Color Tokens (ThemeData)

### Light Mode
| Token | Value | Usage |
|---|---|---|
| `background` | `#F8FBFC` → `#EEF4F6` gradient | Scaffold body |
| `surface` | `rgba(255,255,255,0.6)` + blur | Glass cards, appbar, sheets |
| `surfaceBorder` | `rgba(255,255,255,0.8)` | Card borders |
| `primary` | `#0D9488` (teal 600) | Active chips, toggles, Maps button |
| `primaryGradient` | `#0D9488` → `#14B8A6` | Primary action buttons |
| `secondary` | `#F97316` (orange 500) | Secondary sparks, DoorDash, price chips |
| `secondaryGradient` | `#F97316` → `#FB923C` | Help Me Decide button |
| `textPrimary` | `#1A1A2E` | Headings, titles |
| `textSecondary` | `rgba(0,0,0,0.5)` | Body text, subtitles |
| `textMuted` | `rgba(0,0,0,0.35)` | Dates, hints |
| `chipDefault` | `rgba(0,0,0,0.04)` + `rgba(0,0,0,0.06)` border | Unselected chips |
| `shadow` | `rgba(0,0,0,0.04)` | Soft elevation shadows |
| `danger` | `#EF4444` | Clear history, delete |

### Dark Mode
| Token | Value | Usage |
|---|---|---|
| `background` | `#0A0F14` → `#141E26` gradient | Scaffold body |
| `surface` | `rgba(20,30,40,0.7)` + blur | Glass cards, appbar, sheets |
| `surfaceBorder` | `rgba(255,255,255,0.08)` | Card borders |
| `primary` | `#2DD4BF` (teal 400) | Brighter for dark contrast |
| `primaryGradient` | `#0D9488` → `#2DD4BF` | Primary buttons |
| `secondary` | `#FB923C` (orange 400) | Secondary sparks |
| `secondaryGradient` | `#F97316` → `#FDBA74` | Buttons |
| `textPrimary` | `#FFFFFF` | Headings |
| `textSecondary` | `rgba(255,255,255,0.6)` | Body |
| `textMuted` | `rgba(255,255,255,0.35)` | Dates |
| `chipDefault` | `rgba(255,255,255,0.04)` + `rgba(255,255,255,0.08)` border | Unselected |
| `shadow` | `rgba(0,0,0,0.3)` | Dark mode shadows |
| `danger` | `#F87171` | Clear/delete |

---

## Flutter Implementation Strategy

### 1. Theme Architecture
- Create `lib/theme/app_theme.dart` with `ThemeData` for light and dark
- Create `lib/theme/app_colors.dart` with color token constants
- Use `Theme.of(context)` everywhere instead of hardcoded colors
- Store user's mode preference in `SharedPreferences` (`theme_mode: 'light' | 'dark' | 'system'`)

### 2. Glassmorphism in Flutter
Flutter doesn't have CSS `backdrop-filter`. Workarounds:
- **AppBar**: Use `SystemUiOverlayStyle` + semi-transparent `Color` with no blur (acceptable on mobile)
- **Cards/Sheets**: Use `Container` with `color: Colors.white.withOpacity(0.6)` + `BoxShadow` for depth. On iOS, `BackdropFilter` with `ImageFilter.blur` can work behind the widget if placed in a `Stack`.
- **Simpler approach**: Use opacity layers with subtle borders. The "glass" look is 80% opacity + border + shadow. True blur is a nice-to-have.

### 3. Gradient Text
- Winner name uses `ShaderMask` with `LinearGradient` in Flutter
- AppBar title can stay plain white/dark for readability

### 4. Gradient Buttons
- Wrap `ElevatedButton` in `Container` with `BoxDecoration` gradient
- Or use `MaterialButton` with custom decoration

### 5. Toggle Switches
- Flutter's `Switch` widget adapts to theme automatically if `ThemeData` is set correctly
- But for the custom teal/amber look, we may need a custom toggle widget

### 6. Radial Glow Orbs
- `Container` with `BoxDecoration` using `RadialGradient` at very low opacity (0.06–0.12)
- Positioned in a `Stack` behind content, `pointer-events: none` equivalent via `IgnorePointer`

---

## Files to Modify

| File | Changes |
|---|---|
| `lib/main.dart` | Replace all `Color.fromARGB` with theme tokens. Wrap `MaterialApp` with `ThemeProvider`. Add radial glows behind body. |
| `lib/filter_screen.dart` | Use themed chips, slider, backgrounds. |
| `lib/settings.dart` | Use themed toggles, list items, input fields. |
| `lib/location_service.dart` | No UI changes needed. |
| **NEW** `lib/theme/app_theme.dart` | `ThemeData` definitions for light + dark |
| **NEW** `lib/theme/app_colors.dart` | Color token constants |
| **NEW** `lib/theme/theme_provider.dart` | `ChangeNotifier` for theme mode switching |
| **NEW** `lib/widgets/glass_card.dart` | Reusable glassmorphism card widget |
| **NEW** `lib/widgets/gradient_button.dart` | Reusable gradient pill button |
| **NEW** `lib/widgets/gradient_text.dart` | Reusable gradient text widget |
| **NEW** `lib/widgets/glow_orb.dart` | Reusable radial glow background orb |

---

## Implementation Order

1. **Create theme infrastructure** — `app_colors.dart`, `app_theme.dart`, `theme_provider.dart`
2. **Create reusable widgets** — `GlassCard`, `GradientButton`, `GradientText`, `GlowOrb`
3. **Refactor `main.dart`** — Home screen, Random Result, Head-to-Head, History Sheet
4. **Refactor `filter_screen.dart`** — Filters screen
5. **Refactor `settings.dart`** — Settings screen
6. **Add theme toggle** — Settings screen gets a "Appearance" row (System / Light / Dark)
7. **Test both modes** — Screenshot light and dark side-by-side

---

## Acceptance Criteria
- [ ] App launches in light mode by default
- [ ] Dark mode switchable from Settings
- [ ] All screens render correctly in both modes
- [ ] Glassmorphism visible on cards, appbar, bottom sheet
- [ ] Gradient buttons and gradient winner text working
- [ ] Glow orbs visible behind home/random result screens
- [ ] No hardcoded colors remain outside `app_colors.dart`
- [ ] Screenshots of light + dark modes delivered to Captain

---

## Notes
- Glassmorphism on Android: `BackdropFilter` can be slow. Use opacity + borders as fallback.
- iOS: `BackdropFilter` with `ImageFilter.blur(sigmaX: 20, sigmaY: 20)` works well.
- We can detect platform and adjust blur intensity.
- Store theme preference key: `'app_theme_mode'` in SharedPreferences

---

**Estimated effort**: 2–3 hours of focused implementation + testing
**Risk**: Low. Purely cosmetic refactor, no business logic changes.
