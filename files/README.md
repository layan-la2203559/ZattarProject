# VAULT-O-MATIC — Flutter App

Retro terminal-style wallet app. Tracks balance, debts, and spending limits.
Data saved locally as `vault_data.json` on the device.

---

## Setup (one time)

### 1. Install Flutter
Download from https://flutter.dev/docs/get-started/install
Follow the guide for your OS (Windows/Mac/Linux).

Run this to confirm everything works:
```
flutter doctor
```
All items should have green checkmarks.

---

### 2. Put the project files in a folder

Create a folder called `vault_o_matic` and place these files inside it
exactly as structured:

```
vault_o_matic/
├── pubspec.yaml
├── android/
│   └── app/src/main/AndroidManifest.xml
└── lib/
    ├── main.dart
    ├── data_store.dart
    ├── retro_theme.dart
    ├── sounds.dart
    └── screens/
        ├── wallet_screen.dart
        ├── debts_screen.dart
        └── plan_screen.dart
```

---

### 3. Install dependencies

Open a terminal inside the `vault_o_matic` folder and run:
```
flutter pub get
```

---

## Run on your phone

1. Enable **Developer Mode** on your Android phone:
   - Go to Settings → About Phone
   - Tap **Build Number** 7 times
   - Go back to Settings → Developer Options
   - Turn on **USB Debugging**

2. Connect your phone via USB cable

3. Run:
```
flutter devices
```
Your phone should appear in the list.

4. Run the app:
```
flutter run
```

---

## Build a release APK to install on any Android phone

```
flutter build apk --release
```

Your APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Transfer it to your phone and tap to install.
(You may need to allow "Install from unknown sources" in Settings.)

---

## Notes

- Data is saved to `vault_data.json` in the app's private documents folder on device
- Sounds are generated in pure Dart — no audio files needed
- Tested on Flutter 3.x, Dart 3.x
- iOS builds require a Mac with Xcode
