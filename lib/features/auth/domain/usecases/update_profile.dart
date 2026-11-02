import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;
  UpdateProfile(this.repository);

  Future<AppUser> call({
    String? displayName,
    String? paymentFrequency,
    double? paymentAmount,
  }) {
    return repository.updateProfile(
      displayName: displayName,
      paymentFrequency: paymentFrequency,
      paymentAmount: paymentAmount,
    );
  }
}