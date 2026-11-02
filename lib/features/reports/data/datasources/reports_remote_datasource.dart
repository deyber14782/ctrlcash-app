import '../../../../core/network/api_client.dart';
import '../models/reports_model.dart';

class ReportsRemoteDataSource {
  final ApiClient apiClient;
  ReportsRemoteDataSource(this.apiClient);

  Future<ReportsModel> getReports({
    String? period,
    String? from,
    String? to,
  }) async {
    final res = await apiClient.dio.get(
      '/reports',
      queryParameters: {
        if (period != null) 'period': period,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    return ReportsModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<Map<String, dynamic>> getAnalysis({
    required String type,
    String? period,
    String? from,
    String? to,
  }) async {
    final res = await apiClient.dio.get(
      '/reports/analysis/$type',
      queryParameters: {
        if (period != null) 'period': period,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    return Map<String, dynamic>.from(res.data);
  }
}
