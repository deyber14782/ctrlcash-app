import '../repositories/budgets_repository.dart';

class DeleteBudget {
  final BudgetsRepository repository;
  DeleteBudget(this.repository);
  Future<void> call(String id) => repository.deleteBudget(id);
}