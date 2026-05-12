# TERE System — Setup

Flutter Web app for barangay emergency response and community communication.

## Prerequisites

- Flutter SDK 3.10+ (`flutter --version`)
- Firebase CLI (`npm install -g firebase-tools` → `firebase login`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

## One-time Firebase setup

1. Create a Firebase project at https://console.firebase.google.com (any project ID; e.g. `tere-barangay-system`).
2. From the project root, run:

   ```powershell
   flutterfire configure --platforms=web
   ```

   Pick the project from the list. This generates `lib/firebase_options.dart` and registers a Web app in the Firebase console (overwrites the placeholder).
3. In the Firebase console:
   - **Authentication > Sign-in method**: enable **Email/Password**.
   - **Firestore Database**: Create database in `asia-southeast1` (production mode).
   - **Storage**: Get started, same region.
   - **Project settings > Cloud Messaging > Web configuration**: generate a **Web Push certificate (VAPID key pair)**. Copy the public key into `AppConstants.fcmVapidPublicKey` in `lib/core/constants/app_constants.dart`.
   - **Project settings > Your apps > Web**: copy the `firebaseConfig` object and paste the values into `web/firebase-messaging-sw.js` (replace each `REPLACE_ME`).
4. Deploy security rules and indexes:

   ```powershell
   firebase deploy --only firestore:rules,firestore:indexes,storage:rules
   ```

## Running locally

```powershell
flutter pub get
flutter run -d chrome --web-port=5000
```

A fixed port (5000) keeps OAuth redirect URIs and the FCM service-worker scope consistent across reloads.

## Roles

The app supports three roles in `users/{uid}.role`:

- `resident` — default for self-signup
- `official` — verifies/manages incidents, broadcasts alerts (set manually in Firebase console)
- `admin` — everything plus user management (set manually in Firebase console)

To promote a user, edit their `users/{uid}` document in Firestore and change `role` to `official` or `admin`.

## Project layout

```
lib/
  main.dart, firebase_options.dart
  app/                 router, theme, root widget
  core/                constants, services, utils, errors
  features/
    auth/              login, register, onboarding, providers, repository
    home/              alerts/dashboard landing
    incidents/         (Phase 2) report, my reports, classifier
    alerts/            (Phase 3) feed + barangay scoping
    admin/             (Phase 4) verify, broadcast, user management
    community/         (Phase 5) announcements feed
  shared/widgets/      app scaffold, role gate, loading/error/empty/coming-soon
web/
  index.html, firebase-messaging-sw.js
firestore.rules, storage.rules, firebase.json, firestore.indexes.json
```
