import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/create_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import 'expenses_state.dart';
import '../../domain/usecases/update_expense.dart';

class ExpensesNotifier extends Notifier<ExpensesState> {
  late final GetExpenses _getExpenses;
  late final CreateExpense _createExpense;
  late final DeleteExpense _deleteExpense;
  late final UpdateExpense _updateExpense;

  @override
  ExpensesState build() {
    _getExpenses = sl();
    _createExpense = sl();
    _deleteExpense = sl();
    _updateExpense = sl();
    return const ExpensesState();
  }

  Future<void> load() async {
    state = state.copyWith(status: ExpensesStatus.loading, errorMessage: null);
    try {
      final expenses = await _getExpenses();
      state = state.copyWith(status: ExpensesStatus.loaded, expenses: expenses);
    } catch (e) {
      state = state.copyWith(
        status: ExpensesStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  bool _adding = false;

  Future<bool> add({
    required double amount,
    required String name,
    required String priority,
    required String category,
    String description = '',
  }) async {
    if (_adding) return false;
    _adding = true;
    try {
      await _createExpense(
        amount: amount,
        name: name,
        priority: priority,
        category: category,
        description: description,
      );
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ExpensesStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    } finally {
      _adding = false;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _deleteExpense(id);
      await load();
    } catch (e) {
      state = state.copyWith(
        status: ExpensesStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<String?> update({
    required String id,
    required double amount,
    required String name,
    required String priority,
    required String category,
  }) async {
    try {
      await _updateExpense(
        id: id,
        amount: amount,
        name: name,
        priority: priority,
        category: category,
      );
      await load();
      return null; // éxito
    } catch (e) {
      return e.toString(); // el error crudo, lo humanizamos en la UI
    }
  }

  void setSearch(String value) {
    state = state.copyWith(search: value);
  }

  void setPriorityFilter(String value) {
    state = state.copyWith(priorityFilter: value);
  }

  void setCategoryFilter(String value) {
    state = state.copyWith(categoryFilter: value);
  }

  void setSort(ExpenseSort sort) {
    state = state.copyWith(sort: sort);
  }
}

final expensesNotifierProvider =
    NotifierProvider<ExpensesNotifier, ExpensesState>(ExpensesNotifier.new);