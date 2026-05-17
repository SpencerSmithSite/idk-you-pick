# Architecture Guide — Liquid Glass Widget System

Last updated: 2026-05-16

## Overview
The Liquid Glass design system replaces the older Aurora Frost glass-card system with an Apple-inspired fluid material implemented via Flutter primitives.

## Core Widgets (6 files in `lib/widgets/`)

| File | Responsibility | Key Parameters |
|------|---------------|---------------|
| `liquid_glass.dart` | Core glass widget | `blur` (σ), `opacity`, `borderRadius`, `elevation` |
| `liquid_glass_app_bar.dart` | Transparent blurred app bar | `title`, `actions`, `leading`, `blur`, `opacity` |
| `liquid_glass_button.dart` | Pressable glass button | `label`, `icon`, `onPressed`, `variant` (primary / secondary) |
| `liquid_glass_overlay.dart` | Modal background overlay | `child`, `onDismiss` — near-transparent (α≈0.12) |
| `liquid_glass_scaffold.dart` | Stack-based scaffold | `body`, `appBar` — body renders *under* app bar for true transparency |
| `glass_card.dart` *(deprecated)* | Thin redirect to `LiquidGlass` | Preserves backward compatibility for external imports |

## Design Tokens (`lib/theme/app_colors.dart`)
- `glassSurface` — base glass tint
- `glassEdge` — refraction highlight color (white at low alpha)
- `glassBlurLight` / `glassBlurMedium` / `glassBlurHeavy` — blur sigma presets
- `glassOverlay` — modal overlay background

## Screen-Level Conventions
- Every screen uses `LiquidGlassScaffold` instead of `Scaffold`.
- App bars are `LiquidGlassAppBar` (transparent, no `Material` elevation).
- Primary CTAs are `LiquidGlassButton` (animates opacity + scale on press).
- Bottom sheets and modals use `LiquidGlassOverlay` as background with `LiquidGlass` content card.
- Cards displaying data (restaurant info, settings) use `LiquidGlass` with `glassBlurMedium`.

## Migration Path
Old code using `GlassCard(...)` still works because `glass_card.dart` now wraps `LiquidGlass(...)`.
Old code using `GradientButton(...)` must migrate to `LiquidGlassButton(...)` — `gradient_button.dart` was deleted outright.
Old code using `GlowOrb(...)` must remove it — the glowing blob aesthetic is incompatible with Liquid Glass.

## Performance Notes
- `BackdropFilter` is the most expensive part. We keep blur values ≤ 45σ to stay within iOS GPU budget.
- Avoid nesting multiple `LiquidGlass` widgets (e.g., glass card inside glass card) — combine into one surface instead.
- On older Android devices, heavy blur may drop frames; consider a fallback solid-surface mode (not yet implemented).

## QA Checklist for Liquid Glass Changes
1. `flutter analyze` — zero issues.
2. `flutter test` — all passing.
3. `flutter build ios --simulator` — builds without errors.
4. Visual smoke-test: all 8 screens look correct with glass surfaces.
5. Text readability: white text over glass must have ≥ WCAG 2.1 AA contrast against underlying dark content.
