import '../entities/debt.dart';
import '../repositories/debts_repository.dart';

class CreateDebt {
  final DebtsRepository repository;
  CreateDebt(this.repository);
  Future<Debt> call({
    required String name,
    required double amount,
    required double interestRate,
    required int installments,
  }) {
    return repository.createDebt(
      name: name, amount: amount, interestRate: interestRate, installments: installments);
  }
}