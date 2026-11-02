import 'package:ctrlcashapp/features/auth/domain/usecases/change_password.dart';
import 'package:ctrlcashapp/features/auth/domain/usecases/send_password_reset.dart';
import 'package:ctrlcashapp/features/auth/domain/usecases/update_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/complete_financial_profile.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final RegisterUser _registerUser;
  late final LoginUser _loginUser;
  late final GetProfile _getProfile;
  late final LogoutUser _logoutUser;
  late final CompleteFinancialProfile _completeProfile;
  late final UpdateProfile _updateProfile;
  late final SendPasswordReset _sendPasswordReset;
  late final ChangePassword _changePassword;

  @override
  AuthState build() {
    _registerUser = sl();
    _loginUser = sl();
    _getProfile = sl();
    _logoutUser = sl();
    _completeProfile = sl();
    _updateProfile = sl();
    _sendPasswordReset = sl();
    _changePassword = sl();
    return const AuthState();
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
    required int age,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _registerUser(
        email: email,
        password: password,
        displayName: displayName,
        age: age,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _loginUser(email: email, password: password);
      final user = await _getProfile();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _logoutUser();
    state = const AuthState();
  }

  Future<void> loadProfile() async {
    try {
      final user = await _getProfile();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> completeFinancialProfile({
    required String paymentFrequency,
    required double paymentAmount,
  }) async {
    try {
      await _completeProfile(
        paymentFrequency: paymentFrequency,
        paymentAmount: paymentAmount,
      );
      await loadProfile();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? paymentFrequency,
    double? paymentAmount,
  }) async {
    try {
      final user = await _updateProfile(
        displayName: displayName,
        paymentFrequency: paymentFrequency,
        paymentAmount: paymentAmount,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _sendPasswordReset(email);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null; // éxito
    } catch (e) {
      // Devolvemos el mensaje para que la UI lo muestre
      final msg = e.toString();
      if (msg.contains('wrong-password') ||
          msg.contains('invalid-credential')) {
        return 'La contraseña actual es incorrecta';
      }
      if (msg.contains('weak-password')) {
        return 'La nueva contraseña es muy débil (mínimo 6 caracteres)';
      }
      return 'No se pudo cambiar la contraseña';
    }
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
