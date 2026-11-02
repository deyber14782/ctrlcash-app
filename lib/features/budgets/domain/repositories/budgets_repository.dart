import '../entities/budget.dart';

abstract class BudgetsRepository {
  Future<List<Budget>> getBudgets();
  Future<Budget> createBudget({required String category, required double amount});
  Future<Budget> updateBudget({required String id, required double amount});
  Future<void> deleteBudget(String id);
}