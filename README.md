# Farmulan 2

## LINK TO DEMO VIDEO: https://drive.google.com/file/d/17dsf9IUm-cG2yG_PU2prHnpHq_Y7OTsa/view?usp=sharing

## LINK TO GITHUB REPOSITORY: https://github.com/dkokonkwo/farmulan.git

## Project Overview

Welcome to Farmulan! This is a Flutter project designed to help farmers manage their crops, and provide real-time sensor data from on-farm sensors.

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

1.  **Clone the repository:**

    ```bash
    git clone [https://github.com/your-username/farmulan.git](https://github.com/dkokonkwo/farmulan.git)
    cd farmulan
    ```

2.  **Install Dependencies:**

    Navigate to the project's root directory (where `pubspec.yaml` is located) and run the following command to fetch all the dependencies listed in `pubspec.yaml`:

    ```bash
    flutter pub get
    ```

    This command reads the `pubspec.yaml` file, downloads all the required packages (dependencies) from [pub.dev](https://pub.dev/), and makes them available for your project. You should see output similar to:

    ```
    Resolving dependencies...
    (various package downloads and resolutions)
    Got dependencies!
    ```

### Running the Project

Once the dependencies are installed, you can run the application on an emulator, simulator, or a physical device.

1.  **Start an Emulator/Simulator or Connect a Device:**
    * **Android Emulator:** Open Android Studio, go to `Tools > Device Manager`, and start a virtual device.
    * **iOS Simulator (macOS only):** Open Xcode, go to `Xcode > Open Developer Tool > Simulator`.
    * **Physical Device:** Enable USB debugging on your Android device or enable Developer Mode on your iOS device and connect it to your computer via USB.

2.  **Verify Connected Devices:**
    You can check if Flutter detects your device by running:

    ```bash
    flutter devices
    ```

    You should see your connected device listed.

3.  **Run the Application:**
    With a device or emulator running and selected, execute the following command from the project's root directory:

    ```bash
    flutter run
    ```

    This command will build the application and deploy it to your selected device/emulator. The first build might take some time.

    For debug mode, you'll see output similar to the one you provided earlier:

    ```
    Launching lib\main.dart on sdk gphone64 x86 64 in debug mode...
    Running Gradle task 'assembleDebug'...
    ...
    Debug service listening on ws://127.0.0.1:XXXXX/ws
    Syncing files to device sdk gphone64 x86 64...
    ```

    Your app should now be running on your device!

