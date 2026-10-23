import 'package:local_auth/local_auth.dart';

/// Unlocks the app with the device's biometrics or screen lock.
abstract interface class AppLocker {
  /// Whether the device has any screen lock (biometric, PIN, pattern or
  /// password) that can protect the app.
  Future<bool> isAvailable();

  /// Shows the system prompt. Returns `true` when the user was verified.
  Future<bool> authenticate(String reason);
}

class DeviceAppLocker implements AppLocker {
  final _auth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      // biometricOnly: false lets the device PIN/pattern work as a fallback,
      // so the user is never locked out of their own data.
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }
}
