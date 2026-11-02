import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> register({
    required String email,
    required String password,
    String? displayName,
    required int age,
  });

  Future<void> login({required String email, required String password});

  Future<AppUser> getProfile();

  Future<void> logout();

  Future<void> completeFinancialProfile({
    required String paymentFrequency,
    required double paymentAmount,
  });

  Future<AppUser> updateProfile({
    String? displayName,
    String? paymentFrequency,
    double? paymentAmount,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
