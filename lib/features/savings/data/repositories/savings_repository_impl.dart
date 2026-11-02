import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_repository.dart';
import '../datasources/savings_remote_datasource.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final SavingsRemoteDataSource remoteDataSource;
  SavingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SavingsGoal>> getGoals() => remoteDataSource.getGoals();

  @override
  Future<SavingsGoal> createGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
  }) {
    return remoteDataSource.createGoal(
        name: name, targetAmount: targetAmount, deadline: deadline);
  }

  @override
  Future<SavingsGoal> contribute({required String id, required double amount}) {
    return remoteDataSource.contribute(id: id, amount: amount);
  }

  @override
  Future<void> deleteGoal(String id) => remoteDataSource.deleteGoal(id);
}