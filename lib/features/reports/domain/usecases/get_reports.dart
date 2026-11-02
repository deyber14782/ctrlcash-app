import '../entities/reports.dart';
import '../repositories/reports_repository.dart';

class GetReports {
  final ReportsRepository repository;
  GetReports(this.repository);
  Future<Reports> call({String? period, String? from, String? to}) =>
      repository.getReports(period: period, from: from, to: to);
}