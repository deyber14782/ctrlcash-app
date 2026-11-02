import '../repositories/debts_repository.dart';

class DeleteDebt {
  final DebtsRepository repository;
  DeleteDebt(this.repository);
  Future<void> call(String id) => repository.deleteDebt(id);
}