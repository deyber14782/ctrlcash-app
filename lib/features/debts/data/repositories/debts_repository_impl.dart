import '../../domain/entities/debt.dart';
import '../../domain/entities/amortization.dart';
import '../../domain/repositories/debts_repository.dart';
import '../datasources/debts_remote_datasource.dart';

class DebtsRepositoryImpl implements DebtsRepository {
  final DebtsRemoteDataSource remoteDataSource;
  DebtsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Debt>> getDebts() => remoteDataSource.getDebts();

  @override
  Future<Debt> createDebt({
    required String name,
    required double amount,
    required double interestRate,
    required int installments,
  }) {
    return remoteDataSource.createDebt({
      'name': name,
      'amount': amount,
      'interestRate': interestRate,
      'installments': installments,
    });
  }

  @override
  Future<Amortization> getAmortization(String id) =>
      remoteDataSource.getAmortization(id);

  @override
  Future<void> deleteDebt(String id) => remoteDataSource.deleteDebt(id);

  @override
  Future<Debt> updateDebt({
    required String id,
    required String name,
    required double amount,
    required double interestRate,
    required int installments,
  }) {
    return remoteDataSource.updateDebt(
      id: id,
      name: name,
      amount: amount,
      interestRate: interestRate,
      installments: installments,
    );
  }
}
