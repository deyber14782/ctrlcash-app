import '../../domain/entities/reports.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;
  ReportsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Reports> getReports({String? period, String? from, String? to}) =>
      remoteDataSource.getReports(period: period, from: from, to: to);

  @override
  Future<String> getAnalysis({
    required String type,
    String? period,
    String? from,
    String? to,
  }) async {
    final res = await remoteDataSource.getAnalysis(
      type: type,
      period: period,
      from: from,
      to: to,
    );
    return res['analysis'] as String? ?? '';
  }
}
