import '../entities/debt.dart';
import '../entities/amortization.dart';

abstract class DebtsRepository {
  Future<List<Debt>> getDebts();
  Future<Debt> createDebt({
    required String name,
    required double amount,
    required double interestRate,
    required int installments,
  });
  Future<Amortization> getAmortization(String id);
  Future<void> deleteDebt(String id);
  Future<Debt> updateDebt({
    required String id,
    required String name,
    required double amount,
    required double interestRate,
    required int installments,
  });
}
