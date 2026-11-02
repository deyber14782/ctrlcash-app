import '../../domain/entities/expense.dart';

enum ExpensesStatus { initial, loading, loaded, error }

enum ExpenseSort { recent, oldest, highest, lowest }

class ExpensesState {
  final ExpensesStatus status;
  final List<Expense> expenses; // lista completa (sin filtrar)
  final String? errorMessage;

  // Filtros
  final String search;
  final String priorityFilter; // 'todos' | 'alta' | 'baja'
  final String categoryFilter; // 'todas' | 'comida' | 'transporte' | ...
  final ExpenseSort sort;

  const ExpensesState({
    this.status = ExpensesStatus.initial,
    this.expenses = const [],
    this.errorMessage,
    this.search = '',
    this.priorityFilter = 'todos',
    this.categoryFilter = 'todas',
    this.sort = ExpenseSort.recent,
  });

  // Total sobre la lista completa (no la filtrada)
  double get total => expenses.fold(0, (sum, e) => sum + e.amount);

  // Lista con búsqueda, filtro y orden aplicados
  List<Expense> get filtered {
    var list = [...expenses];

    // Búsqueda por nombre
    if (search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((e) => e.name.toLowerCase().contains(q)).toList();
    }

    // Filtro por prioridad
    if (priorityFilter != 'todos') {
      list = list.where((e) => e.priority == priorityFilter).toList();
    }

    // Filtro por categoría
    if (categoryFilter != 'todas') {
      list = list.where((e) => e.category == categoryFilter).toList();
    }

    // Orden
    switch (sort) {
      case ExpenseSort.recent:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case ExpenseSort.oldest:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case ExpenseSort.highest:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case ExpenseSort.lowest:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return list;
  }

  // Total de la lista filtrada (útil para mostrar "total de lo buscado")
  double get filteredTotal => filtered.fold(0, (sum, e) => sum + e.amount);

  ExpensesState copyWith({
    ExpensesStatus? status,
    List<Expense>? expenses,
    String? errorMessage,
    String? search,
    String? priorityFilter,
    String? categoryFilter,
    ExpenseSort? sort,
  }) {
    return ExpensesState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      errorMessage: errorMessage,
      search: search ?? this.search,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      sort: sort ?? this.sort,
    );
  }
}