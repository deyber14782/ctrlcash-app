import '../../domain/entities/income.dart';

enum IncomeStatus { initial, loading, loaded, error }

enum IncomeSort { recent, oldest, highest, lowest }

class IncomeState {
  final IncomeStatus status;
  final List<Income> incomes;
  final String? errorMessage;

  final String search;
  final IncomeSort sort;

  const IncomeState({
    this.status = IncomeStatus.initial,
    this.incomes = const [],
    this.errorMessage,
    this.search = '',
    this.sort = IncomeSort.recent,
  });

  double get total => incomes.fold(0, (sum, e) => sum + e.amount);

  List<Income> get filtered {
    var list = [...incomes];

    if (search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((e) => e.name.toLowerCase().contains(q)).toList();
    }

    switch (sort) {
      case IncomeSort.recent:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case IncomeSort.oldest:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case IncomeSort.highest:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case IncomeSort.lowest:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return list;
  }

  IncomeState copyWith({
    IncomeStatus? status,
    List<Income>? incomes,
    String? errorMessage,
    String? search,
    IncomeSort? sort,
  }) {
    return IncomeState(
      status: status ?? this.status,
      incomes: incomes ?? this.incomes,
      errorMessage: errorMessage,
      search: search ?? this.search,
      sort: sort ?? this.sort,
    );
  }
}