import '../repositories/income_repository.dart';

class DeleteIncome {
  final IncomeRepository repository;
  DeleteIncome(this.repository);
  Future<void> call(String id) => repository.deleteIncome(id);
}