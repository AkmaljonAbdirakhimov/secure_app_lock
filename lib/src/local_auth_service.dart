import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();
  static const pinKey = 'user_pin';
  static const lockEnabledKey = 'lock_enabled';
  static const biometricsEnabledKey = 'biometrics_enabled';

  Future<void> savePin(String pin) async {
    await _storage.write(key: pinKey, value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: pinKey);
  }

  Future<void> saveLockEnabled(bool enabled) async {
    await _storage.write(key: lockEnabledKey, value: enabled ? 'true' : 'false');
  }

  Future<bool> getLockEnabled() async {
    final value = await _storage.read(key: lockEnabledKey);
    return value == 'true';
  }

  Future<void> saveBiometricsEnabled(bool enabled) async {
    await _storage.write(key: biometricsEnabledKey, value: enabled ? 'true' : 'false');
  }

  Future<bool> getBiometricsEnabled() async {
    final value = await _storage.read(key: biometricsEnabledKey);
    return value == 'true';
  }

  Future<bool> authenticateWithBiometrics({String? localizedReason}) async {
    bool canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) return false;

    return await _auth.authenticate(
      localizedReason: localizedReason ?? 'Please authenticate to access the app',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }
}
