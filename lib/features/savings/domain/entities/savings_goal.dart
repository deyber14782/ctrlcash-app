import 'package:equatable/equatable.dart';

class Contribution extends Equatable {
  final double amount;
  final DateTime date;
  const Contribution({required this.amount, required this.date});

  @override
  List<Object?> get props => [amount, date];
}

class SavingsGoal extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final List<Contribution> contributions;
  final int percentage;
  final bool completed;
  final DateTime createdAt;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.contributions,
    required this.percentage,
    required this.completed,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, name, targetAmount, currentAmount, deadline,
        contributions, percentage, completed, createdAt,
      ];
}