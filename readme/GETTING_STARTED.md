# Getting Started with KSKT Rider

Welcome to **KSKT Rider** (From Farm to Kitchen - Kisaan Se Kitchen Tak). This guide walks you through setting up, configuring, and running the application on your local machine or device.

---

## Prerequisites

Ensure you have the following installed on your machine:

1. **Flutter SDK**: `^3.13.0` or higher (compatible with Dart `^3.13.3`)
   - Check installation: `flutter --version`
2. **Android Studio** / **VS Code** with Flutter and Dart extensions.
3. **Android SDK / Emulator** (or physical Android device with Developer Mode enabled).
4. **Git**: For version control.

---

## Installation & Setup

### 1. Clone or Open the Repository
```bash
cd e:/project/ridetrack
```

### 2. Install Dependencies
Fetch the required Flutter packages:
```bash
flutter pub get
```

### 3. Verify Flutter Doctor
Check your environment health:
```bash
flutter doctor
```

---

## Platform Permissions

### Android
Ensure the following permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.ACCESS_COARSE_LOCATION`
- `android.permission.ACCESS_BACKGROUND_LOCATION` (if background tracking is required)
- `android.permission.INTERNET`

### iOS
Ensure the following keys are present in `ios/Runner/Info.plist`:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

---

## Running the Application

### Debug Mode
Run on an attached emulator or device:
```bash
flutter run
```

### Hot Reload / Hot Restart
- Press **`r`** in the terminal to perform a Hot Reload.
- Press **`R`** (Shift + R) to perform a Hot Restart.
- Press **`q`** to quit.

---

## Project Scripts & Verification

- **Analyze Code**:
  ```bash
  flutter analyze
  ```
- **Run Unit Tests**:
  ```bash
  flutter test
  ```
