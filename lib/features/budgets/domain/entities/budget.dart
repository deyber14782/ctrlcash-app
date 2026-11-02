import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String category;
  final double amount;
  final double spent;
  final int percentage;
  final String status; // 'ok' | 'warning' | 'over'
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.spent,
    required this.percentage,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, category, amount, spent, percentage, status, createdAt];
}