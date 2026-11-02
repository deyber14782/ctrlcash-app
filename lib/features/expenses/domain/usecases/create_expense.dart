import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

class CreateExpense {
  final ExpensesRepository repository;
  CreateExpense(this.repository);

  Future<Expense> call({
    required double amount,
    required String name,
    required String priority,
    required String category,
    String description = '',
    DateTime? date,
  }) {
    return repository.createExpense(
      amount: amount,
      name: name,
      priority: priority,
      category: category,
      description: description,
      date: date,
    );
  }
}