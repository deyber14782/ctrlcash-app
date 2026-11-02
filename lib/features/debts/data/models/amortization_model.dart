import '../../domain/entities/amortization.dart';

class AmortizationModel extends Amortization {
  const AmortizationModel({
    required super.monthlyPayment,
    required super.totalPaid,
    required super.totalInterest,
    required super.schedule,
  });

  factory AmortizationModel.fromJson(Map<String, dynamic> json) {
    final list = (json['schedule'] as List).cast<Map<String, dynamic>>();
    return AmortizationModel(
      monthlyPayment: (json['monthlyPayment'] as num).toDouble(),
      totalPaid: (json['totalPaid'] as num).toDouble(),
      totalInterest: (json['totalInterest'] as num).toDouble(),
      schedule: list.map((r) => AmortizationRow(
        number: (r['number'] as num).toInt(),
        payment: (r['payment'] as num).toDouble(),
        principal: (r['principal'] as num).toDouble(),
        interest: (r['interest'] as num).toDouble(),
        balance: (r['balance'] as num).toDouble(),
      )).toList(),
    );
  }
}