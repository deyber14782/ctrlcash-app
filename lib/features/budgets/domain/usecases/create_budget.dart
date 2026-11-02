import '../entities/budget.dart';
import '../repositories/budgets_repository.dart';

class CreateBudget {
  final BudgetsRepository repository;
  CreateBudget(this.repository);
  Future<Budget> call({required String category, required double amount}) {
    return repository.createBudget(category: category, amount: amount);
  }
}