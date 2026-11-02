import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_budgets.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/delete_budget.dart';
import 'budgets_state.dart';

class BudgetsNotifier extends Notifier<BudgetsState> {
  late final GetBudgets _getBudgets;
  late final CreateBudget _createBudget;
  late final DeleteBudget _deleteBudget;

  @override
  BudgetsState build() {
    _getBudgets = sl();
    _createBudget = sl();
    _deleteBudget = sl();
    return const BudgetsState();
  }

  Future<void> load() async {
    state = state.copyWith(status: BudgetsStatus.loading, errorMessage: null);
    try {
      final budgets = await _getBudgets();
      state = state.copyWith(status: BudgetsStatus.loaded, budgets: budgets);
    } catch (e) {
      state = state.copyWith(status: BudgetsStatus.error, errorMessage: e.toString());
    }
  }

  bool _adding = false;

  Future<String?> add({required String category, required double amount}) async {
    if (_adding) return 'Espera un momento';
    _adding = true;
    try {
      await _createBudget(category: category, amount: amount);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _adding = false;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _deleteBudget(id);
      await load();
    } catch (e) {
      state = state.copyWith(status: BudgetsStatus.error, errorMessage: e.toString());
    }
  }
}

final budgetsNotifierProvider =
    NotifierProvider<BudgetsNotifier, BudgetsState>(BudgetsNotifier.new);