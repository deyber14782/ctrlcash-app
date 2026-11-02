import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyEnabled = 'biometric_enabled';       // bloqueo de app
  static const _keyLoginEnabled = 'biometric_login';    // login con huella
  static const _keyEmail = 'biometric_email';
  static const _keyPassword = 'biometric_password';

  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Verifica tu identidad para acceder a CtrlCash',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  // ---- Bloqueo de app (lo que ya teníamos) ----
  Future<bool> isEnabled() async {
    final value = await _storage.read(key: _keyEnabled);
    return value == 'true';
  }

  Future<void> setEnabled(bool enabled) async {
    await _storage.write(key: _keyEnabled, value: enabled ? 'true' : 'false');
  }

  // ---- Login con huella (nuevo) ----

  // ¿Está activado el login con huella?
  Future<bool> isLoginEnabled() async {
    final value = await _storage.read(key: _keyLoginEnabled);
    return value == 'true';
  }

  // Guarda las credenciales cifradas y activa el login con huella
  Future<void> enableLogin({required String email, required String password}) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyLoginEnabled, value: 'true');
  }

  // Desactiva el login con huella y borra las credenciales
  Future<void> disableLogin() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    await _storage.write(key: _keyLoginEnabled, value: 'false');
  }

  // Recupera las credenciales guardadas (después de verificar la huella)
  Future<({String email, String password})?> getSavedCredentials() async {
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    if (email == null || password == null) return null;
    return (email: email, password: password);
  }
}