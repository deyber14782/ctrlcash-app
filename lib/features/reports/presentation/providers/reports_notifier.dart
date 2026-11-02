import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_reports.dart';
import 'reports_state.dart';

class ReportsNotifier extends Notifier<ReportsState> {
  late final GetReports _getReports;

  @override
  ReportsState build() {
    _getReports = sl();
    return const ReportsState();
  }

  // Periodo predefinido
  Future<void> loadPeriod(String period) async {
    state = state.copyWith(
        status: ReportsStatus.loading, period: period, from: null, to: null, errorMessage: null);
    await _fetch(period: period);
  }

  // Rango personalizado
  Future<void> loadRange(DateTime from, DateTime to) async {
    state = state.copyWith(
        status: ReportsStatus.loading, period: 'custom', from: from, to: to, errorMessage: null);
    await _fetch(from: from, to: to);
  }

  Future<void> load() async {
    if (state.period == 'custom' && state.from != null && state.to != null) {
      await _fetch(from: state.from, to: state.to);
    } else {
      await _fetch(period: state.period);
    }
  }

  Future<void> _fetch({String? period, DateTime? from, DateTime? to}) async {
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final reports = await _getReports(
        period: from != null ? null : period,
        from: from != null ? fmt.format(from) : null,
        to: to != null ? fmt.format(to) : null,
      );
      state = state.copyWith(status: ReportsStatus.loaded, reports: reports);
    } catch (e) {
      state = state.copyWith(status: ReportsStatus.error, errorMessage: e.toString());
    }
  }
}

final reportsNotifierProvider =
    NotifierProvider<ReportsNotifier, ReportsState>(ReportsNotifier.new);