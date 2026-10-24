import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static final SecurityService instance = SecurityService._internal();
  factory SecurityService() => instance;
  SecurityService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  static const String _keyAppLockEnabled = 'jx_app_lock_enabled';
  static const String _keyFirstRunCompleted = 'jx_first_run_completed';

  bool _isDeviceSupported = false;
  bool _canCheckBiometrics = false;

  Future<void> init() async {
    try {
      _isDeviceSupported = await _auth.isDeviceSupported();
      _canCheckBiometrics = await _auth.canCheckBiometrics;
    } catch (e) {
      _isDeviceSupported = false;
      _canCheckBiometrics = false;
    }
  }

  bool get isDeviceSupported => _isDeviceSupported;
  bool get canCheckBiometrics => _canCheckBiometrics;

  Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAppLockEnabled) ?? false;
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAppLockEnabled, enabled);
  }

  Future<bool> isFirstRunCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstRunCompleted) ?? false;
  }

  Future<void> setFirstRunCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstRunCompleted, completed);
  }

  /// Authenticate using Android's official BiometricPrompt / Device Credential.
  /// Does NOT collect or store PINs, passwords, or biometrics.
  Future<({bool success, String? errorMessage})> authenticate({
    String reason = 'Authenticate to access JX Secure Assistant',
  }) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows device PIN / Pattern fallback securely via Android OS
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      return (success: didAuthenticate, errorMessage: didAuthenticate ? null : 'Authentication was not completed');
    } on PlatformException catch (e) {
      String msg = 'Authentication error: ${e.message}';
      if (e.code == 'NotAvailable') {
        msg = 'Biometrics and device lock credentials are not configured on this device.';
      } else if (e.code == 'PasscodeNotSet') {
        msg = 'No device PIN or screen lock set in Android Settings.';
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        msg = 'Too many failed attempts. Please unlock via device screen lock.';
      }
      return (success: false, errorMessage: msg);
    } catch (e) {
      return (success: false, errorMessage: 'Failed to verify device credentials: $e');
    }
  }
}
