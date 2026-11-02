import '../entities/debt.dart';
import '../repositories/debts_repository.dart';

class UpdateDebt {
  final DebtsRepository repository;
  UpdateDebt(this.repository);
  Future<Debt> call({
    required String id,
    required String name,
    required double amount,
    required double interestRate,
    required int installments,
  }) {
    return repository.updateDebt(
      id: id, name: name, amount: amount,
      interestRate: interestRate, installments: installments);
  }
}