import '../entities/income.dart';

abstract class IncomeRepository {
  Future<List<Income>> getIncome();
  Future<Income> createIncome({
    required double amount,
    required String name,
    DateTime? date,
  });
  Future<void> deleteIncome(String id);
  Future<Income> updateIncome({
    required String id,
    required double amount,
    required String name,
  });
}
