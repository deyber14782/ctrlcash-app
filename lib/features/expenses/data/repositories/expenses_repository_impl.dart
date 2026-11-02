import '../../domain/entities/expense.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_remote_datasource.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesRemoteDataSource remoteDataSource;
  ExpensesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Expense>> getExpenses() => remoteDataSource.getExpenses();

  @override
  Future<Expense> createExpense({
    required double amount,
    required String name,
    required String priority,
    required String category,
    String description = '',
    DateTime? date,
  }) {
    return remoteDataSource.createExpense({
      'amount': amount,
      'name': name,
      'priority': priority,
      'category': category,
      'description': description,
      if (date != null) 'date': date.toIso8601String(),
    });
  }

  @override
  Future<void> deleteExpense(String id) => remoteDataSource.deleteExpense(id);

  @override
  Future<Expense> updateExpense({
    required String id,
    required double amount,
    required String name,
    required String priority,
    required String category,
  }) {
    return remoteDataSource.updateExpense(
      id: id,
      amount: amount,
      name: name,
      priority: priority,
      category: category,
    );
  }
}