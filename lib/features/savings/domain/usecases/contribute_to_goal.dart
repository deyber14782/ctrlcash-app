import '../entities/savings_goal.dart';
import '../repositories/savings_repository.dart';

class ContributeToGoal {
  final SavingsRepository repository;
  ContributeToGoal(this.repository);
  Future<SavingsGoal> call({required String id, required double amount}) {
    return repository.contribute(id: id, amount: amount);
  }
}