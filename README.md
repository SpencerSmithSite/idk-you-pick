![image](https://github.com/user-attachments/assets/4b47a03d-4b9d-4882-92c3-9533fd4f440b)
![image](https://github.com/user-attachments/assets/a7669239-bff7-47f4-8386-d59ad68ff99d)
![image](https://github.com/user-attachments/assets/1aa4df8f-317c-43d5-87b1-ce070bd14e0f)

# IDK-What-Do-You-Want

[![Deploy to Firebase Hosting](https://github.com/SpencerSmithSite/IDK-what-do-YOU-want/actions/workflows/firebase-hosting-merge.yml/badge.svg)](https://github.com/SpencerSmithSite/IDK-what-do-YOU-want/actions/workflows/firebase-hosting-merge.yml)

A restaurant decision-making app that helps you choose where to eat when you (or your partner) can't decide. Built with Flutter and deployed to Firebase Hosting.

## Features

### Random Restaurant Selection
- Get a random restaurant suggestion when you can't decide
- Filter by cuisine type, price range, and distance
- Save favorite suggestions for future reference

### Head-to-Head Comparison Mode
- Compare two restaurants side by side
- View key details like ratings, price range, and cuisine type
- Make an informed decision with all the facts

### Price Bracket Battle
- Pick a price tier ($, $$, $$$) and battle through bracket rounds
- Fun way to narrow down choices by budget

### Search & Sort
- Live text search across name, cuisine, type, and tags
- Sort by name, distance, price, cuisine, or random

### Lunchtime Suggestions
- Scheduled local push notifications with a daily restaurant suggestion
- Respects your filters and 7-day history to avoid repeats

### Data Export / Import
- Export your favorites, history, and settings to a JSON file
- Import back from a file to restore or migrate devices

### Customizable Restaurant List
- Create and manage multiple restaurant lists
- Organize restaurants by categories or preferences
- Share lists with friends and family

### Custom Restaurant Saving
- Add your own restaurants to the database
- Include custom notes and ratings
- Upload photos of your favorite dishes

### Beautiful Modern UI
- Clean and intuitive interface
- Dark and light mode support
- Smooth animations and transitions
- Responsive design for all screen sizes
- Aurora Frost glassmorphism theme

## Technology Stack

- **Frontend Framework**: Flutter
- **State Management**: StatefulWidget + SharedPreferences (local persistence)
- **Data Storage**: JSON assets + SharedPreferences (favorites, history, settings)
- **Location**: Geolocator + Geocoding
- **Push Notifications**: flutter_local_notifications + timezone
- **Background Tasks**: workmanager
- **Version Control**: Git
- **Build System**: Gradle (Android), CocoaPods (iOS)
- **CI/CD**: GitHub Actions (test, build, deploy preview)

## Getting Started

1. Clone the repository
2. Install Flutter dependencies
3. Set up your Google Places API key
4. Run the app using `flutter run`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE Version 3 - see the [LICENSE](LICENSE) file for details.
