# Secure App Lock

A Flutter package that provides secure app lock functionality with PIN code and biometric authentication support. This package allows you to easily add app-level security to your Flutter applications by requiring users to authenticate when the app comes back from the background.

## Features

- **PIN Code Authentication**: Set up a 4-digit PIN code for app access
- **Biometric Authentication**: Support for fingerprint, face recognition, and other biometric methods
- **Automatic Locking**: Automatically locks the app when it goes to background
- **Lifecycle Management**: Handles app lifecycle states to trigger authentication
- **Secure Storage**: Uses Flutter Secure Storage to securely store PIN codes and settings
- **Customizable UI**: Provides default PIN entry screen with option to use custom lock screens

## Getting started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  secure_app_lock: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Platform Setup

#### Android
Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

#### iOS
Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID for secure authentication</string>
```

## Usage

### Basic Setup

1. Wrap your main app with `AppLockLifecycleWatcher`:

```dart
import 'package:flutter/material.dart';
import 'package:secure_app_lock/secure_app_lock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: AppLockLifecycleWatcher(
        navigatorKey: navigatorKey,
        child: HomePage(),
      ),
    );
  }
}
```

### Managing App Lock

```dart
import 'package:secure_app_lock/secure_app_lock.dart';

class SettingsPage extends StatelessWidget {
  final lockController = SecureLock.lockController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Security Settings')),
      body: Column(
        children: [
          // Enable/Disable app lock
          ListenableBuilder(
            listenable: lockController,
            builder: (context, child) {
              return SwitchListTile(
                title: Text('App Lock'),
                value: lockController.enabled,
                onChanged: (value) {
                  if (value) {
                    // Navigate to PIN setup
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PinCodePage(),
                      ),
                    );
                  } else {
                    lockController.disable();
                  }
                },
              );
            },
          ),
          
          // Biometrics toggle
          ListenableBuilder(
            listenable: lockController,
            builder: (context, child) {
              return SwitchListTile(
                title: Text('Biometric Authentication'),
                value: lockController.biometricsEnabled,
                onChanged: lockController.enabled 
                  ? (value) => lockController.toggleBiometrics()
                  : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### Custom Lock Screen

You can provide your own custom lock screen:

```dart
AppLockLifecycleWatcher(
  navigatorKey: navigatorKey,
  lockScreen: CustomLockScreen(), // Your custom widget
  child: HomePage(),
)
```

### Manual Authentication

```dart
// Check if biometric authentication is available and authenticate
bool success = await SecureLock.lockController.tryBiometricUnlock();

// Manually lock the app
SecureLock.lockController.lock();

// Manually unlock the app
SecureLock.lockController.unlock();
```

## API Reference

### SecureLock

Main entry point for accessing the app lock controller.

```dart
static final AppLockController lockController = AppLockController();
```

### AppLockController

Controls the app lock state and provides authentication methods.

**Properties:**
- `bool locked` - Whether the app is currently locked
- `bool enabled` - Whether app lock is enabled
- `bool biometricsEnabled` - Whether biometric authentication is enabled
- `String? pin` - Current PIN code (encrypted)

**Methods:**
- `setPin(String pin)` - Set a new PIN code
- `lock()` - Lock the app
- `unlock()` - Unlock the app
- `enable()` - Enable app lock
- `disable()` - Disable app lock
- `toggleBiometrics()` - Toggle biometric authentication
- `tryBiometricUnlock()` - Attempt biometric authentication

### AppLockLifecycleWatcher

Widget that monitors app lifecycle and triggers authentication when needed.

### PinCodePage

Default PIN code entry screen with setup and authentication modes.

## Additional information

This package uses the following dependencies:
- `flutter_secure_storage` for secure data storage
- `local_auth` for biometric authentication

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Issues

Please file issues on the [GitHub repository](https://github.com/AkmaljonAbdirakhimov/secure_app_lock/issues).

### License

This project is licensed under the MIT License - see the LICENSE file for details.
