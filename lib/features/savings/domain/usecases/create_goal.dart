import '../entities/savings_goal.dart';
import '../repositories/savings_repository.dart';

class CreateGoal {
  final SavingsRepository repository;
  CreateGoal(this.repository);
  Future<SavingsGoal> call({
    required String name,
    required double targetAmount,
    DateTime? deadline,
  }) {
    return repository.createGoal(name: name, targetAmount: targetAmount, deadline: deadline);
  }
}