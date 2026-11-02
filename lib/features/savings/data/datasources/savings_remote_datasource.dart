import '../../../../core/network/api_client.dart';
import '../models/savings_goal_model.dart';

class SavingsRemoteDataSource {
  final ApiClient apiClient;
  SavingsRemoteDataSource(this.apiClient);

  Future<List<SavingsGoalModel>> getGoals() async {
    final res = await apiClient.dio.get('/savings-goals');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(SavingsGoalModel.fromJson).toList();
  }

  Future<SavingsGoalModel> createGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
  }) async {
    final res = await apiClient.dio.post('/savings-goals', data: {
      'name': name,
      'targetAmount': targetAmount,
      if (deadline != null) 'deadline': deadline.toIso8601String(),
    });
    return SavingsGoalModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<SavingsGoalModel> contribute({
    required String id,
    required double amount,
  }) async {
    final res = await apiClient.dio.post('/savings-goals/$id/contribute', data: {
      'amount': amount,
    });
    return SavingsGoalModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteGoal(String id) async {
    await apiClient.dio.delete('/savings-goals/$id');
  }
}