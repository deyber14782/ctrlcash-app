import '../../../../core/network/api_client.dart';
import '../models/income_model.dart';

class IncomeRemoteDataSource {
  final ApiClient apiClient;
  IncomeRemoteDataSource(this.apiClient);

  Future<List<IncomeModel>> getIncome() async {
    final res = await apiClient.dio.get('/income');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(IncomeModel.fromJson).toList();
  }

  Future<IncomeModel> createIncome(Map<String, dynamic> data) async {
    final res = await apiClient.dio.post('/income', data: data);
    return IncomeModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteIncome(String id) async {
    await apiClient.dio.delete('/income/$id');
  }

  Future<IncomeModel> updateIncome({
    required String id,
    required double amount,
    required String name,
  }) async {
    final res = await apiClient.dio.put(
      '/income/$id',
      data: {'amount': amount, 'name': name},
    );
    return IncomeModel.fromJson(Map<String, dynamic>.from(res.data));
  }
}
