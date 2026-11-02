import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    String? displayName,
    required int age,
  }) {
    return remoteDataSource.register(
      email: email,
      password: password,
      displayName: displayName,
      age: age,
    );
  }

  @override
  Future<void> login({required String email, required String password}) {
    return remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<AppUser> getProfile() => remoteDataSource.getProfile();

  @override
  Future<void> logout() => remoteDataSource.logout();

  @override
  Future<void> completeFinancialProfile({
    required String paymentFrequency,
    required double paymentAmount,
  }) {
    return remoteDataSource.completeFinancialProfile(
      paymentFrequency: paymentFrequency,
      paymentAmount: paymentAmount,
    );
  }

  @override
  Future<AppUser> updateProfile({
    String? displayName,
    String? paymentFrequency,
    double? paymentAmount,
  }) {
    return remoteDataSource.updateProfile(
      displayName: displayName,
      paymentFrequency: paymentFrequency,
      paymentAmount: paymentAmount,
    );
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      remoteDataSource.sendPasswordReset(email);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
