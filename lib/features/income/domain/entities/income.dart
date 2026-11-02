import 'package:equatable/equatable.dart';

class Income extends Equatable {
  final String id;
  final double amount;
  final String name;
  final DateTime date;
  final DateTime createdAt;

  const Income({
    required this.id,
    required this.amount,
    required this.name,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, amount, name, date, createdAt];
}