import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.category,
    required super.amount,
    required super.spent,
    required super.percentage,
    required super.status,
    required super.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'otros',
      amount: (json['amount'] as num).toDouble(),
      spent: (json['spent'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'ok',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}