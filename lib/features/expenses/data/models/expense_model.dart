import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.amount,
    required super.name,
    required super.priority,
    required super.category,
    required super.description,
    required super.date,
    required super.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    // createdAt puede faltar en gastos viejos: usamos date como respaldo
    DateTime parsedCreatedAt;
    final rawCreated = json['createdAt'];
    if (rawCreated is String && rawCreated.isNotEmpty) {
      parsedCreatedAt = DateTime.parse(rawCreated);
    } else {
      parsedCreatedAt = DateTime.parse(json['date'] as String);
    }

    return ExpenseModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      name: json['name'] as String? ?? '',
      priority: json['priority'] as String? ?? 'baja',
      category: json['category'] as String? ?? 'otros',
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      createdAt: parsedCreatedAt,
    );
  }
}