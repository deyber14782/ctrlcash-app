import '../entities/debt.dart';
import '../repositories/debts_repository.dart';

class GetDebts {
  final DebtsRepository repository;
  GetDebts(this.repository);
  Future<List<Debt>> call() => repository.getDebts();
}