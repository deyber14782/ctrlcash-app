import '../../../../core/network/api_client.dart';
import '../models/debt_model.dart';
import '../models/amortization_model.dart';

class DebtsRemoteDataSource {
  final ApiClient apiClient;
  DebtsRemoteDataSource(this.apiClient);

  Future<List<DebtModel>> getDebts() async {
    final res = await apiClient.dio.get('/debts');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(DebtModel.fromJson).toList();
  }

  Future<DebtModel> createDebt(Map<String, dynamic> data) async {
    final res = await apiClient.dio.post('/debts', data: data);
    return DebtModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<AmortizationModel> getAmortization(String id) async {
    final res = await apiClient.dio.get('/debts/$id/amortization');
    return AmortizationModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteDebt(String id) async {
    await apiClient.dio.delete('/debts/$id');
  }

  Future<DebtModel> updateDebt({
    required String id,
    required String name,
    required double amount,
    required double interestRate,
    required int installments,
  }) async {
    final res = await apiClient.dio.put(
      '/debts/$id',
      data: {
        'name': name,
        'amount': amount,
        'interestRate': interestRate,
        'installments': installments,
      },
    );
    return DebtModel.fromJson(Map<String, dynamic>.from(res.data));
  }
}
