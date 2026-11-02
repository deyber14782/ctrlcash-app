import '../repositories/savings_repository.dart';

class DeleteGoal {
  final SavingsRepository repository;
  DeleteGoal(this.repository);
  Future<void> call(String id) => repository.deleteGoal(id);
}