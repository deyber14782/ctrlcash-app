import '../repositories/auth_repository.dart';

class CompleteFinancialProfile {
  final AuthRepository repository;
  CompleteFinancialProfile(this.repository);

  Future<void> call({
    required String paymentFrequency,
    required double paymentAmount,
  }) {
    return repository.completeFinancialProfile(
      paymentFrequency: paymentFrequency,
      paymentAmount: paymentAmount,
    );
  }
}