import '../entities/income.dart';
import '../repositories/income_repository.dart';

class UpdateIncome {
  final IncomeRepository repository;
  UpdateIncome(this.repository);
  Future<Income> call({
    required String id,
    required double amount,
    required String name,
  }) {
    return repository.updateIncome(id: id, amount: amount, name: name);
  }
}