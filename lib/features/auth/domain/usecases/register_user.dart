import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;
  RegisterUser(this.repository);

  Future<AppUser> call({
    required String email,
    required String password,
    String? displayName,
    required int age,
  }) {
    return repository.register(
      email: email,
      password: password,
      displayName: displayName,
      age: age,
    );
  }
}