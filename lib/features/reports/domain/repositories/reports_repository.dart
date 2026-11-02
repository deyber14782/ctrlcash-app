import '../entities/reports.dart';

abstract class ReportsRepository {
  Future<Reports> getReports({String? period, String? from, String? to});
  Future<String> getAnalysis({
    required String type,
    String? period,
    String? from,
    String? to,
  });
}
