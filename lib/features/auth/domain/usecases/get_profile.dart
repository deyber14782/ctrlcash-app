import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetProfile {
  final AuthRepository repository;
  GetProfile(this.repository);

  Future<AppUser> call() => repository.getProfile();
}