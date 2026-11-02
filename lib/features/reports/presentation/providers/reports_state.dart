import '../../domain/entities/reports.dart';

enum ReportsStatus { initial, loading, loaded, error }

class ReportsState {
  final ReportsStatus status;
  final Reports? reports;
  final String period; // all | month | 3months | custom
  final DateTime? from;
  final DateTime? to;
  final String? errorMessage;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.reports,
    this.period = 'all',
    this.from,
    this.to,
    this.errorMessage,
  });

  ReportsState copyWith({
    ReportsStatus? status,
    Reports? reports,
    String? period,
    DateTime? from,
    DateTime? to,
    String? errorMessage,
  }) {
    return ReportsState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      period: period ?? this.period,
      from: from ?? this.from,
      to: to ?? this.to,
      errorMessage: errorMessage,
    );
  }
}