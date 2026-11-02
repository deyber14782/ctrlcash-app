import '../../domain/entities/debt.dart';

class DebtModel extends Debt {
  const DebtModel({
    required super.id,
    required super.name,
    required super.amount,
    required super.interestRate,
    required super.installments,
    required super.createdAt,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    // createdAt puede faltar en deudas viejas: usamos la fecha actual como respaldo
    DateTime parsedCreatedAt;
    final rawCreated = json['createdAt'];
    if (rawCreated is String && rawCreated.isNotEmpty) {
      parsedCreatedAt = DateTime.parse(rawCreated);
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return DebtModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      installments: (json['installments'] as num).toInt(),
      createdAt: parsedCreatedAt,
    );
  }
}