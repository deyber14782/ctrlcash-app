import '../entities/budget.dart';
import '../repositories/budgets_repository.dart';

class GetBudgets {
  final BudgetsRepository repository;
  GetBudgets(this.repository);
  Future<List<Budget>> call() => repository.getBudgets();
}