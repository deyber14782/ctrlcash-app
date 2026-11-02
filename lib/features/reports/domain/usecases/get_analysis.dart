import '../repositories/reports_repository.dart';

class GetAnalysis {
  final ReportsRepository repository;
  GetAnalysis(this.repository);
  Future<String> call({
    required String type,
    String? period,
    String? from,
    String? to,
  }) {
    return repository.getAnalysis(type: type, period: period, from: from, to: to);
  }
}