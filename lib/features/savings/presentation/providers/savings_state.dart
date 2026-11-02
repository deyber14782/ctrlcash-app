import '../../domain/entities/savings_goal.dart';

enum SavingsStatus { initial, loading, loaded, error }

class SavingsState {
  final SavingsStatus status;
  final List<SavingsGoal> goals;
  final String? errorMessage;

  const SavingsState({
    this.status = SavingsStatus.initial,
    this.goals = const [],
    this.errorMessage,
  });

  SavingsState copyWith({
    SavingsStatus? status,
    List<SavingsGoal>? goals,
    String? errorMessage,
  }) {
    return SavingsState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
      errorMessage: errorMessage,
    );
  }
}