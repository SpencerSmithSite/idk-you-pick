![image](https://github.com/user-attachments/assets/4b47a03d-4b9d-4882-92c3-9533fd4f440b)
![image](https://github.com/user-attachments/assets/a7669239-bff7-47f4-8386-d59ad68ff99d)
![image](https://github.com/user-attachments/assets/1aa4df8d-317c-43d5-87b1-ce070bd14e0f)

# IDK You Pick

[![Deploy to Firebase Hosting](https://github.com/SpencerSmithSite/IDK-what-do-YOU-want/actions/workflows/firebase-hosting-merge.yml/badge.svg)](https://github.com/SpencerSmithSite/IDK-what-do-YOU-want/actions/workflows/firebase-hosting-merge.yml)

A restaurant decision-making app that helps you choose where to eat when you (or your partner) can't decide. Built with Flutter for iOS and Android.

## Features

| Phase | Feature | Status |
|-------|---------|--------|
| 1 | **Rich Restaurant Data** — 54 local restaurants with cuisine, type, price tier, tags, lat/lng, phone, and website | ✅ |
| 2 | **Smart Filters** — multi-select chips for cuisine, type, and price tier with SharedPreferences persistence | ✅ |
| 3 | **Location Mode** — GPS-based distance filtering with Haversine formula, 1–25 mi radius slider | ✅ |
| 4 | **Action Links** — one-tap open in Maps, DoorDash, Call, or Website from any restaurant card | ✅ |
| 5 | **History / Seen Tracking** — mark restaurants as tried, avoid repeats with 7-day history, clear/remove individual entries | ✅ |
| 6 | **Share & Invite** — share winner details via system share sheet, generate deep-link invites with embedded filters | ✅ |
| 7 | **Onboarding** — 4-slide walkthrough for first-time users, "How It Works" overlay, demo mode | ✅ |
| 8 | **Restaurant Detail** — full-screen detail with chips, actions, favorite toggle, custom scroll view | ✅ |
| 9 | **Favorites** — dedicated favorites list with swipe-to-remove, tap-to-detail, empty state | ✅ |
| 10 | **Search & Sort** — live text search across name, cuisine, type, tags; sort by name, distance, price, cuisine, random | ✅ |
| 11 | **Aurora Frost Theme** — light/dark mode, glassmorphism cards, gradient buttons, glow orbs, complete design system | ✅ |
| 12 | **Testing & QA** — 86+ unit and widget tests, CI lint gate (`flutter analyze`), iOS sim build check | ✅ |
| 13 | **Store Prep** — Dynamic Type support, screen-reader semantics, privacy policy, App Store description, screenshot scripts | ✅ |
| 14 | **Post-Launch Polish** — haptic feedback on every major interaction, in-app review prompt (3-pick threshold, 30-day cooldown), About tile with version/build info, debounced search, scroll physics tuning | ✅ |
| 16 | **Price Bracket Battle** — pick a price tier (`$`, `$$`, `$$$`) and battle through bracket rounds to narrow by budget | ✅ |
| 17 | **Lunchtime Suggestions** — opt-in daily local push notification at 12:15 PM with a smart restaurant pick (respects filters, 7-day deduplication) | ✅ |
| 18 | **Data Export / Import** — export favorites, history, and settings to JSON; import back with validation and summary | ✅ |
| 19 | **Deep Links** — `idkyoupick://` scheme for restaurant and invite links, cold-start handling | ✅ |

### Decision Modes
- **Choose For Me** — instant random pick from your filtered pool
- **Help Me Decide** — head-to-head bracket tournament; pick your favorite in each matchup until one winner remains
- **Price Bracket Battle** — same bracket mechanics, but restricted to a single price tier

### Customization
- **Filters** — cuisine, restaurant type, price tier, and distance (when location is enabled)
- **Favorites** — heart any restaurant and browse your saved list
- **History** — track where you've already eaten and optionally exclude repeats
- **Themes** — System, Light, or Dark mode with Aurora Frost design tokens
- **Demo Mode** — toggle synthetic data in Settings for quick testing

## Technology Stack

- **Framework**: Flutter 3.29+ (Dart ^3.7.2)
- **State Management**: `StatefulWidget` + `SharedPreferences`
- **Data**: JSON asset bundle (`assets/restaurants.json`) for restaurant catalog
- **Persistence**: `SharedPreferences` for filters, favorites, history, settings, and onboarding state
- **Location**: `geolocator` + `geocoding`
- **Deep Links & Sharing**: `app_links` + `share_plus`
- **Notifications**: `flutter_local_notifications` + `timezone` + `workmanager`
- **Store Integration**: `in_app_review`, `package_info_plus`
- **Data Portability**: `file_picker` (import), `share_plus` (export)
- **Utilities**: `url_launcher`, `clipboard`
- **CI/CD**: GitHub Actions (`flutter analyze`, `flutter test`, `flutter build ios --simulator`)
- **Build Targets**: iOS, Android, macOS, Web (Firebase Hosting)

## Getting Started

1. Clone the repository
2. Ensure Flutter is installed and `flutter doctor` passes
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE Version 3 — see the [LICENSE](LICENSE) file for details.
