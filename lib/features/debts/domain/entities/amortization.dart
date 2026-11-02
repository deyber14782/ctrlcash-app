import 'package:equatable/equatable.dart';

class AmortizationRow extends Equatable {
  final int number;
  final double payment;
  final double principal;
  final double interest;
  final double balance;

  const AmortizationRow({
    required this.number,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });

  @override
  List<Object?> get props => [number, payment, principal, interest, balance];
}

class Amortization extends Equatable {
  final double monthlyPayment;
  final double totalPaid;
  final double totalInterest;
  final List<AmortizationRow> schedule;

  const Amortization({
    required this.monthlyPayment,
    required this.totalPaid,
    required this.totalInterest,
    required this.schedule,
  });

  @override
  List<Object?> get props => [monthlyPayment, totalPaid, totalInterest, schedule];
}