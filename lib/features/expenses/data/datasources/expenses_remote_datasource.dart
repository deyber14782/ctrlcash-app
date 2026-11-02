import '../../../../core/network/api_client.dart';
import '../models/expense_model.dart';

class ExpensesRemoteDataSource {
  final ApiClient apiClient;
  ExpensesRemoteDataSource(this.apiClient);

  Future<List<ExpenseModel>> getExpenses() async {
    final res = await apiClient.dio.get('/expenses');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(ExpenseModel.fromJson).toList();
  }

  Future<ExpenseModel> createExpense(Map<String, dynamic> data) async {
    final res = await apiClient.dio.post('/expenses', data: data);
    return ExpenseModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteExpense(String id) async {
    await apiClient.dio.delete('/expenses/$id');
  }

  Future<ExpenseModel> updateExpense({
    required String id,
    required double amount,
    required String name,
    required String priority,
    required String category,
  }) async {
    final res = await apiClient.dio.put(
      '/expenses/$id',
      data: {
        'amount': amount,
        'name': name,
        'priority': priority,
        'category': category,
      },
    );
    return ExpenseModel.fromJson(Map<String, dynamic>.from(res.data));
  }
}