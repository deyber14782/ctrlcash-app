import '../entities/expense.dart';

abstract class ExpensesRepository {
  Future<List<Expense>> getExpenses();
  Future<Expense> createExpense({
    required double amount,
    required String name,
    required String priority,
    required String category,
    String description,
    DateTime? date,
  });
  Future<void> deleteExpense(String id);
  Future<Expense> updateExpense({
    required String id,
    required double amount,
    required String name,
    required String priority,
    required String category,
  });
}