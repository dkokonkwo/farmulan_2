````markdown
# Farmulan 2

## LINK TO DEMO VIDEO: [https://drive.google.com/file/d/1njG8iUwFdbK3KjjRQGCBr8pGUVTXlkbL/view?usp=sharing](https://drive.google.com/file/d/1njG8iUwFdbK3KjjRQGCBr8pGUVTXlkbL/view?usp=sharing)

## LINK TO FLUTTER REPOSITORY: [https://github.com/dkokonkwo/farmulan_2.git](https://github.com/dkokonkwo/farmulan_2.git)

## LINK TO HARDWARE CODE REPOSITORY: [https://github.com/dkokonkwo/farmulan_hardware.git](https://github.com/dkokonkwo/farmulan_hardware.git)

## APK LOCATION

The Android APK for Farmulan 2 is available in the root directory of this repository:

```bash
farmulan.apk
````

## Project Overview

Welcome to Farmulan! This is a Flutter project designed to help farmers manage their crops and provide real-time sensor data from on-farm sensors.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Before you begin, ensure you have the following installed on your system:

* **Flutter SDK:** Follow the official Flutter installation guide: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
* **Git:** For cloning the repository.
* **An IDE (Integrated Development Environment):**

  * [Visual Studio Code](https://code.visualstudio.com/) with the Flutter extension.
  * [Android Studio](https://developer.android.com/studio) with the Flutter plugin.
* **Android SDK (if targeting Android):** Usually comes with Android Studio.
* **Xcode (if targeting iOS):** Required for iOS development on macOS.

### Installation

Follow these steps to get your project up and running:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/dkokonkwo/farmulan_2.git
   cd farmulan_2
   ```

2. **Install Dependencies:**

   Run:

   ```bash
   flutter pub get
   ```

### Running the Project

1. **Start an Emulator/Simulator or Connect a Device:**

   * **Android Emulator:** Open Android Studio → Tools > Device Manager → start a virtual device.
   * **iOS Simulator (macOS only):** Open Xcode → Xcode > Open Developer Tool > Simulator.
   * **Physical Device:** Enable USB debugging on Android or Developer Mode on iOS, then connect via USB.

2. **Verify Connected Devices:**

   ```bash
   flutter devices
   ```

3. **Run the Application:**

   ```bash
   flutter run
   ```

## Firebase Backend Integration

Follow these steps to connect the Flutter frontend with the Firebase backend (Firestore & Cloud Functions):

1. **Set Up Firebase Project**

   * In the [Firebase Console](https://console.firebase.google.com/), create or select your project.
   * Enable **Cloud Firestore** and **Cloud Functions** in the console.
   * Add Android and/or iOS apps in **Project Settings > General**, then download:

     * `google-services.json` → place under `android/app/`
     * `GoogleService-Info.plist` → place under `ios/Runner/`

2. **Install Firebase Packages**
   Add to `pubspec.yaml`:

   ```yaml
   dependencies:
     firebase_core: ^2.0.0
     cloud_firestore: ^4.0.0
     firebase_functions: ^4.0.0
     firebase_auth: ^4.0.0
   ```

   Then run:

   ```bash
   flutter pub get
   ```

3. **Initialize Firebase**
   In `lib/main.dart`:

   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'firebase_options.dart'; // from flutterfire CLI

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(const MyApp());
   }
   ```

   Generate `firebase_options.dart` using the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).

4. **Configure Firestore Collections**

   * **sensors**: stores real-time readings (temperature, humidity, radiation, soil moisture).
   * **schedules**: holds computed ET₀, Kc, and next irrigation time for each plot.

   Example usage in Flutter:

   ```dart
   final firestore = FirebaseFirestore.instance;
   // Listen to sensor data
   firestore.collection('sensors').doc(nodeId).snapshots();
   // Update schedule
   firestore.collection('schedules').doc(plotId).set({
     'nextIrrigation': timestamp,
     // ...other fields
   });
   ```

5. **Deploy Cloud Functions**
   In the `functions/` folder (JavaScript/TypeScript):

   ```bash
   cd functions
   npm install
   npx firebase deploy --only functions
   ```

   * **computeEt0**: triggers on weather updates to calculate ET₀.
   * **scheduleIrrigation**: HTTP function to update irrigation schedules on demand.

6. **Calling Functions from Flutter**

   ```dart
   final functions = FirebaseFunctions.instance;
   final result = await functions.httpsCallable('scheduleIrrigation').call({
     'plotId': plotId,
   });
   ```

7. **Logging & Overrides**

   * Use Firestore snapshots for real-time UI updates.
   * Log manual overrides in a subcollection `schedules/{plotId}/overrides`.

---