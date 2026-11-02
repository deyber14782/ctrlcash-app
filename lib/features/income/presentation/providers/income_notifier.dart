import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_income.dart';
import '../../domain/usecases/create_income.dart';
import '../../domain/usecases/delete_income.dart';
import 'income_state.dart';
import '../../domain/usecases/update_income.dart';

class IncomeNotifier extends Notifier<IncomeState> {
  late final GetIncome _getIncome;
  late final CreateIncome _createIncome;
  late final DeleteIncome _deleteIncome;
  late final UpdateIncome _updateIncome;

  @override
  IncomeState build() {
    _getIncome = sl();
    _createIncome = sl();
    _deleteIncome = sl();
    _updateIncome = sl();
    return const IncomeState();
  }

  Future<void> load() async {
    state = state.copyWith(status: IncomeStatus.loading, errorMessage: null);
    try {
      final incomes = await _getIncome();
      state = state.copyWith(status: IncomeStatus.loaded, incomes: incomes);
    } catch (e) {
      state = state.copyWith(
        status: IncomeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  bool _adding = false;

  Future<bool> add({required double amount, required String name}) async {
    if (_adding) return false;
    _adding = true;
    try {
      await _createIncome(amount: amount, name: name);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: IncomeStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    } finally {
      _adding = false;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _deleteIncome(id);
      await load();
    } catch (e) {
      state = state.copyWith(
        status: IncomeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<String?> update({
    required String id,
    required double amount,
    required String name,
  }) async {
    try {
      await _updateIncome(id: id, amount: amount, name: name);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void setSearch(String value) {
    state = state.copyWith(search: value);
  }

  void setSort(IncomeSort sort) {
    state = state.copyWith(sort: sort);
  }
}

final incomeNotifierProvider = NotifierProvider<IncomeNotifier, IncomeState>(
  IncomeNotifier.new,
);
