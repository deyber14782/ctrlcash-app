import '../entities/savings_goal.dart';
import '../repositories/savings_repository.dart';

class GetGoals {
  final SavingsRepository repository;
  GetGoals(this.repository);
  Future<List<SavingsGoal>> call() => repository.getGoals();
}