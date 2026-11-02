import '../../domain/entities/income.dart';
import '../../domain/repositories/income_repository.dart';
import '../datasources/income_remote_datasource.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeRemoteDataSource remoteDataSource;
  IncomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Income>> getIncome() => remoteDataSource.getIncome();

  @override
  Future<Income> createIncome({
    required double amount,
    required String name,
    DateTime? date,
  }) {
    return remoteDataSource.createIncome({
      'amount': amount,
      'name': name,
      if (date != null) 'date': date.toIso8601String(),
    });
  }

  @override
  Future<void> deleteIncome(String id) => remoteDataSource.deleteIncome(id);

  @override
  Future<Income> updateIncome({
    required String id,
    required double amount,
    required String name,
  }) {
    return remoteDataSource.updateIncome(id: id, amount: amount, name: name);
  }
}
