import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

class UpdateExpense {
  final ExpensesRepository repository;
  UpdateExpense(this.repository);
  Future<Expense> call({
    required String id,
    required double amount,
    required String name,
    required String priority,
    required String category,
  }) {
    return repository.updateExpense(
      id: id,
      amount: amount,
      name: name,
      priority: priority,
      category: category,
    );
  }
}