import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_debts.dart';
import '../../domain/usecases/create_debt.dart';
import '../../domain/usecases/delete_debt.dart';
import 'debts_state.dart';
import '../../domain/usecases/update_debt.dart';

class DebtsNotifier extends Notifier<DebtsState> {
  late final GetDebts _getDebts;
  late final CreateDebt _createDebt;
  late final DeleteDebt _deleteDebt;
  late final UpdateDebt _updateDebt;

  @override
  DebtsState build() {
    _getDebts = sl();
    _createDebt = sl();
    _deleteDebt = sl();
    _updateDebt = sl();
    return const DebtsState();
  }

  Future<void> load() async {
    state = state.copyWith(status: DebtsStatus.loading, errorMessage: null);
    try {
      final debts = await _getDebts();
      state = state.copyWith(status: DebtsStatus.loaded, debts: debts);
    } catch (e) {
      state = state.copyWith(
        status: DebtsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  bool _adding = false;

  Future<bool> add({
    required String name,
    required double amount,
    required double interestRate,
    required int installments,
  }) async {
    if (_adding) return false;
    _adding = true;
    try {
      await _createDebt(
        name: name,
        amount: amount,
        interestRate: interestRate,
        installments: installments,
      );
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: DebtsStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    } finally {
      _adding = false;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _deleteDebt(id);
      await load();
    } catch (e) {
      state = state.copyWith(
        status: DebtsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<String?> update({
    required String id,
    required String name,
    required double amount,
    required double interestRate,
    required int installments,
  }) async {
    try {
      await _updateDebt(
        id: id,
        name: name,
        amount: amount,
        interestRate: interestRate,
        installments: installments,
      );
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void setSearch(String value) {
    state = state.copyWith(search: value);
  }

  void setSort(DebtSort sort) {
    state = state.copyWith(sort: sort);
  }
}

final debtsNotifierProvider = NotifierProvider<DebtsNotifier, DebtsState>(
  DebtsNotifier.new,
);
