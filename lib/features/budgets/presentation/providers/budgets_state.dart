import '../../domain/entities/budget.dart';

enum BudgetsStatus { initial, loading, loaded, error }

class BudgetsState {
  final BudgetsStatus status;
  final List<Budget> budgets;
  final String? errorMessage;

  const BudgetsState({
    this.status = BudgetsStatus.initial,
    this.budgets = const [],
    this.errorMessage,
  });

  BudgetsState copyWith({
    BudgetsStatus? status,
    List<Budget>? budgets,
    String? errorMessage,
  }) {
    return BudgetsState(
      status: status ?? this.status,
      budgets: budgets ?? this.budgets,
      errorMessage: errorMessage,
    );
  }
}