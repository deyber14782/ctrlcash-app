import '../../domain/entities/budget.dart';
import '../../domain/repositories/budgets_repository.dart';
import '../datasources/budgets_remote_datasource.dart';

class BudgetsRepositoryImpl implements BudgetsRepository {
  final BudgetsRemoteDataSource remoteDataSource;
  BudgetsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Budget>> getBudgets() => remoteDataSource.getBudgets();

  @override
  Future<Budget> createBudget({required String category, required double amount}) {
    return remoteDataSource.createBudget(category: category, amount: amount);
  }

  @override
  Future<Budget> updateBudget({required String id, required double amount}) {
    return remoteDataSource.updateBudget(id: id, amount: amount);
  }

  @override
  Future<void> deleteBudget(String id) => remoteDataSource.deleteBudget(id);
}