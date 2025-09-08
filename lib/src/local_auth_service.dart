import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  final _auth = LocalAuthentication();
  static const pinKey = 'user_pin';
  static const lockEnabledKey = 'lock_enabled';
  static const biometricsEnabledKey = 'biometrics_enabled';

  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(pinKey, pin);
  }

  Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(pinKey);
  }

  Future<void> saveLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lockEnabledKey, enabled ? 'true' : 'false');
  }

  Future<bool> getLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(lockEnabledKey);
    return value == 'true';
  }

  Future<void> saveBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(biometricsEnabledKey, enabled ? 'true' : 'false');
  }

  Future<bool> getBiometricsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(biometricsEnabledKey);
    return value == 'true';
  }

  Future<bool> authenticateWithBiometrics({String? localizedReason}) async {
    bool canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) return false;

    return await _auth.authenticate(
      localizedReason: localizedReason ?? 'Please authenticate to access the app',
      options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
    );
  }
}
