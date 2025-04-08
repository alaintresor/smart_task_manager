# Smart Task Manager

A modern Flutter application for efficient task management with Firebase integration and local notifications.

## Features

- Task creation and management
- Firebase Authentication (Email/Password and Google Sign-in)
- Cloud Firestore for data persistence
- Local notifications for task reminders
- Cross-platform support (iOS, Android, Web, macOS, Windows, Linux)

## Architecture

The application follows a clean architecture pattern with the following key components:

- **State Management**: Uses Flutter Riverpod for efficient state management
- **Authentication**: Firebase Auth for user authentication
- **Database**: Cloud Firestore for data storage
- **Notifications**: Flutter Local Notifications for task reminders
- **Local Storage**: Shared Preferences for app settings

## Prerequisites

- Flutter SDK (^3.7.2)
- Dart SDK (^3.7.2)
- Firebase project setup
- Android Studio / VS Code with Flutter extensions
- Git

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd smart_task_manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password and Google Sign-in)
   - Set up Cloud Firestore
   - Download and add the Firebase configuration files:
     - For Android: `google-services.json` to `android/app/`
     - For iOS: `GoogleService-Info.plist` to `ios/Runner/`
     - For Web: Add Firebase configuration to `web/index.html`

4. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart              # Application entry point
├── models/               # Data models
├── screens/              # UI screens
├── services/             # Business logic and services
├── providers/            # Riverpod providers
└── widgets/              # Reusable UI components
```

## Dependencies

- `flutter_riverpod`: State management
- `firebase_core`: Firebase core functionality
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `flutter_local_notifications`: Local notifications
- `shared_preferences`: Local storage
- `google_sign_in`: Google authentication
- `intl`: Internationalization

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
