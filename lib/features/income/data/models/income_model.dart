import '../../domain/entities/income.dart';

class IncomeModel extends Income {
  const IncomeModel({
    required super.id,
    required super.amount,
    required super.name,
    required super.date,
    required super.createdAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    // createdAt puede faltar en ingresos viejos: usamos date como respaldo
    DateTime parsedCreatedAt;
    final rawCreated = json['createdAt'];
    if (rawCreated is String && rawCreated.isNotEmpty) {
      parsedCreatedAt = DateTime.parse(rawCreated);
    } else {
      parsedCreatedAt = DateTime.parse(json['date'] as String);
    }

    return IncomeModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      name: json['name'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      createdAt: parsedCreatedAt,
    );
  }
}