import '../entities/income.dart';
import '../repositories/income_repository.dart';

class CreateIncome {
  final IncomeRepository repository;
  CreateIncome(this.repository);
  Future<Income> call({
    required double amount,
    required String name,
    DateTime? date,
  }) {
    return repository.createIncome(amount: amount, name: name, date: date);
  }
}