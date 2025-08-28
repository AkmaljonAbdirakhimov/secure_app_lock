import 'package:flutter/material.dart';
import 'local_auth_service.dart';

class AppLockController extends ChangeNotifier {
  bool _locked = false;
  bool _enabled = false;
  bool _biometricsEnabled = false;
  bool _isInLockScreen = false;
  String? _pin;
  final _authService = LocalAuthService();

  bool get locked => _locked;
  bool get enabled => _enabled;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get isInLockScreen => _isInLockScreen;
  String? get pin => _pin;

  AppLockController() {
    _loadEnabled();
  }

  void _loadEnabled() async {
    _enabled = await _authService.getLockEnabled();
    _biometricsEnabled = await _authService.getBiometricsEnabled();
    _pin = await _authService.getPin();
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    _pin = pin;
    await _authService.savePin(pin);
    notifyListeners();
  }

  void setisInLockScreen(bool value) {
    _isInLockScreen = value;
    notifyListeners();
  }

  void lock() {
    if (_enabled) {
      _locked = true;
      notifyListeners();
    }
  }

  void unlock() {
    _locked = false;
    notifyListeners();
  }

  Future<bool> tryBiometricUnlock() async {
    if (!_biometricsEnabled) return false;
    final success = await _authService.authenticateWithBiometrics();
    if (success) unlock();
    return success;
  }

  void enable() {
    _enabled = true;
    _authService.saveLockEnabled(true);
    notifyListeners();
  }

  void disable() {
    _enabled = false;
    _authService.saveLockEnabled(false);
    _locked = false;
    notifyListeners();
  }

  void toggleBiometrics() {
    _biometricsEnabled = !_biometricsEnabled;
    _authService.saveBiometricsEnabled(_biometricsEnabled);
    notifyListeners();
  }

  void toggle() {
    if (_enabled) {
      disable();
    } else {
      enable();
    }
  }
}
