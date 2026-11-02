import '../../domain/entities/debt.dart';

enum DebtsStatus { initial, loading, loaded, error }

enum DebtSort { recent, highestAmount, lowestAmount, mostInstallments }

class DebtsState {
  final DebtsStatus status;
  final List<Debt> debts;
  final String? errorMessage;

  final String search;
  final DebtSort sort;

  const DebtsState({
    this.status = DebtsStatus.initial,
    this.debts = const [],
    this.errorMessage,
    this.search = '',
    this.sort = DebtSort.recent,
  });

  double get totalDebt => debts.fold(0, (sum, d) => sum + d.amount);

  List<Debt> get filtered {
    var list = [...debts];

    if (search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((d) => d.name.toLowerCase().contains(q)).toList();
    }

    switch (sort) {
      case DebtSort.recent:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case DebtSort.highestAmount:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case DebtSort.lowestAmount:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case DebtSort.mostInstallments:
        list.sort((a, b) => b.installments.compareTo(a.installments));
        break;
    }

    return list;
  }

  DebtsState copyWith({
    DebtsStatus? status,
    List<Debt>? debts,
    String? errorMessage,
    String? search,
    DebtSort? sort,
  }) {
    return DebtsState(
      status: status ?? this.status,
      debts: debts ?? this.debts,
      errorMessage: errorMessage,
      search: search ?? this.search,
      sort: sort ?? this.sort,
    );
  }
}