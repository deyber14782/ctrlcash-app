import 'package:equatable/equatable.dart';

class Debt extends Equatable {
  final String id;
  final String name;
  final double amount;
  final double interestRate;
  final int installments;
  final DateTime createdAt;

  const Debt({
    required this.id,
    required this.name,
    required this.amount,
    required this.interestRate,
    required this.installments,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, name, amount, interestRate, installments, createdAt];
}