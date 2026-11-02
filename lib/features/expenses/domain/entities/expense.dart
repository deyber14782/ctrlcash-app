import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final double amount;
  final String name;
  final String priority; // 'alta' | 'baja'
  final String category;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.name,
    required this.priority,
    required this.category,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, amount, name, priority, category, description, date, createdAt];
}