import '../../../../core/network/api_client.dart';
import '../models/budget_model.dart';

class BudgetsRemoteDataSource {
  final ApiClient apiClient;
  BudgetsRemoteDataSource(this.apiClient);

  Future<List<BudgetModel>> getBudgets() async {
    final res = await apiClient.dio.get('/budgets');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(BudgetModel.fromJson).toList();
  }

  Future<BudgetModel> createBudget({
    required String category,
    required double amount,
  }) async {
    final res = await apiClient.dio.post('/budgets', data: {
      'category': category,
      'amount': amount,
    });
    return BudgetModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<BudgetModel> updateBudget({
    required String id,
    required double amount,
  }) async {
    final res = await apiClient.dio.put('/budgets/$id', data: {'amount': amount});
    return BudgetModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteBudget(String id) async {
    await apiClient.dio.delete('/budgets/$id');
  }
}