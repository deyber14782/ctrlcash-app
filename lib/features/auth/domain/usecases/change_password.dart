import '../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository repository;
  ChangePassword(this.repository);
  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return repository.changePassword(
      currentPassword: currentPassword, newPassword: newPassword);
  }
}