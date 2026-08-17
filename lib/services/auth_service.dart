import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import 'database_service.dart';
import '../utils/constants.dart';

/// AuthService — PIN hashing (never stores plain text) + biometric auth.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final DatabaseService _db = DatabaseService.instance;

  String _hashPin(String pin) {
    final bytes = utf8.encode('kanakku_thaal_salt_$pin');
    return sha256.convert(bytes).toString();
  }

  Future<void> setPin(String pin) async {
    final settings = _db.settings.get(AppConstants.settingsKey);
    if (settings == null) return;
    settings.pinHash = _hashPin(pin);
    settings.pinEnabled = true;
    await settings.save();
  }

  Future<bool> verifyPin(String pin) async {
    final settings = _db.settings.get(AppConstants.settingsKey);
    if (settings?.pinHash == null) return false;
    return settings!.pinHash == _hashPin(pin);
  }

  Future<void> disablePin() async {
    final settings = _db.settings.get(AppConstants.settingsKey);
    if (settings == null) return;
    settings.pinEnabled = false;
    settings.pinHash = null;
    settings.biometricEnabled = false;
    await settings.save();
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'கணக்கு தாள் ஐ திறக்க அங்கீகரிக்கவும்',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
