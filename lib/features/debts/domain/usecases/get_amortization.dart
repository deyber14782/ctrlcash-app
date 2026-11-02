import '../entities/amortization.dart';
import '../repositories/debts_repository.dart';

class GetAmortization {
  final DebtsRepository repository;
  GetAmortization(this.repository);
  Future<Amortization> call(String id) => repository.getAmortization(id);
}