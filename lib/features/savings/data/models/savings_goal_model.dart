import '../../domain/entities/savings_goal.dart';

class SavingsGoalModel extends SavingsGoal {
  const SavingsGoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    super.deadline,
    required super.contributions,
    required super.percentage,
    required super.completed,
    required super.createdAt,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    final rawContributions = (json['contributions'] as List?) ?? [];
    final contributions = rawContributions.map((c) => Contribution(
          amount: (c['amount'] as num).toDouble(),
          date: DateTime.parse(c['date'] as String),
        )).toList();

    return SavingsGoalModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      contributions: contributions,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}