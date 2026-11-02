import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/network/api_client.dart';
import '../models/app_user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSource(this.apiClient, this.firebaseAuth);

  Future<AppUserModel> register({
    required String email,
    required String password,
    String? displayName,
    required int age,
  }) async {
    final res = await apiClient.dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'displayName': displayName,
        'age': age,
      },
    );
    return AppUserModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> login({required String email, required String password}) async {
    final cred = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<AppUserModel> getProfile() async {
    final res = await apiClient.dio.get('/auth/me');
    return AppUserModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> logout() => firebaseAuth.signOut();

  Future<void> completeFinancialProfile({
    required String paymentFrequency,
    required double paymentAmount,
  }) async {
    await apiClient.dio.put(
      '/users/financial-profile',
      data: {
        'paymentFrequency': paymentFrequency,
        'paymentAmount': paymentAmount,
      },
    );
  }

  Future<AppUserModel> updateProfile({
    String? displayName,
    String? paymentFrequency,
    double? paymentAmount,
  }) async {
    final res = await apiClient.dio.put(
      '/users/profile',
      data: {
        if (displayName != null) 'displayName': displayName,
        if (paymentFrequency != null) 'paymentFrequency': paymentFrequency,
        if (paymentAmount != null) 'paymentAmount': paymentAmount,
      },
    );
    return AppUserModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No hay sesión activa');
    }

    // Re-autenticar con la contraseña actual (requerido por Firebase)
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Ya re-autenticado, cambiar la contraseña
    await user.updatePassword(newPassword);
  }
}
