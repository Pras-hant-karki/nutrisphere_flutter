# nutrisphere_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API Host Configuration

The app supports three API host modes:

1. `API_BASE_URL` (highest priority)
2. Android emulator host (`10.0.2.2`) when `USE_ANDROID_EMULATOR_HOST=true`
3. Android real device host from `compIpAddress` in `lib/core/api/api_endpoints.dart`

Examples:

```bash
# Real Android device on same Wi-Fi
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000

# Android emulator
flutter run --dart-define=USE_ANDROID_EMULATOR_HOST=true
```
