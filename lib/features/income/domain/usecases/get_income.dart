import '../entities/income.dart';
import '../repositories/income_repository.dart';

class GetIncome {
  final IncomeRepository repository;
  GetIncome(this.repository);
  Future<List<Income>> call() => repository.getIncome();
}
