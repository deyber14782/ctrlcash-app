import '../entities/savings_goal.dart';

abstract class SavingsRepository {
  Future<List<SavingsGoal>> getGoals();
  Future<SavingsGoal> createGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
  });
  Future<SavingsGoal> contribute({required String id, required double amount});
  Future<void> deleteGoal(String id);
}