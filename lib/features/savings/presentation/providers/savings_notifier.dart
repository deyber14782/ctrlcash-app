import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_goals.dart';
import '../../domain/usecases/create_goal.dart';
import '../../domain/usecases/contribute_to_goal.dart';
import '../../domain/usecases/delete_goal.dart';
import 'savings_state.dart';

class SavingsNotifier extends Notifier<SavingsState> {
  late final GetGoals _getGoals;
  late final CreateGoal _createGoal;
  late final ContributeToGoal _contributeToGoal;
  late final DeleteGoal _deleteGoal;

  @override
  SavingsState build() {
    _getGoals = sl();
    _createGoal = sl();
    _contributeToGoal = sl();
    _deleteGoal = sl();
    return const SavingsState();
  }

  Future<void> load() async {
    state = state.copyWith(status: SavingsStatus.loading, errorMessage: null);
    try {
      final goals = await _getGoals();
      state = state.copyWith(status: SavingsStatus.loaded, goals: goals);
    } catch (e) {
      state = state.copyWith(status: SavingsStatus.error, errorMessage: e.toString());
    }
  }

  bool _busy = false;

  Future<String?> add({
    required String name,
    required double targetAmount,
    DateTime? deadline,
  }) async {
    if (_busy) return 'Espera un momento';
    _busy = true;
    try {
      await _createGoal(name: name, targetAmount: targetAmount, deadline: deadline);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _busy = false;
    }
  }

  Future<String?> contribute({required String id, required double amount}) async {
    if (_busy) return 'Espera un momento';
    _busy = true;
    try {
      await _contributeToGoal(id: id, amount: amount);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _busy = false;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _deleteGoal(id);
      await load();
    } catch (e) {
      state = state.copyWith(status: SavingsStatus.error, errorMessage: e.toString());
    }
  }
}

final savingsNotifierProvider =
    NotifierProvider<SavingsNotifier, SavingsState>(SavingsNotifier.new);