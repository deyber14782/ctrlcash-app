import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../providers/expenses_notifier.dart';
import '../providers/expenses_state.dart';
import 'add_expense_page.dart';
import 'edit_expense_page.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  static const _categories = {
    'comida': {'label': 'Comida', 'icon': Icons.restaurant},
    'transporte': {'label': 'Transporte', 'icon': Icons.directions_bus},
    'vivienda': {'label': 'Vivienda', 'icon': Icons.home_outlined},
    'entretenimiento': {'label': 'Entretenimiento', 'icon': Icons.movie_outlined},
    'salud': {'label': 'Salud', 'icon': Icons.local_hospital_outlined},
    'educacion': {'label': 'Educación', 'icon': Icons.school_outlined},
    'ropa': {'label': 'Ropa', 'icon': Icons.checkroom_outlined},
    'servicios': {'label': 'Servicios', 'icon': Icons.receipt_long_outlined},
    'otros': {'label': 'Otros', 'icon': Icons.category_outlined},
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expensesNotifierProvider.notifier).load();
    });
  }

  bool _canEdit(DateTime createdAt) {
    return DateTime.now().difference(createdAt).inHours < 24;
  }

  String _categoryLabel(String value) =>
      _categories[value]?['label'] as String? ?? 'Otros';

  IconData _categoryIcon(String value) =>
      _categories[value]?['icon'] as IconData? ?? Icons.category_outlined;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expensesNotifierProvider);
    final fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gastos'),
        backgroundColor: AppColors.background,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.5),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.accent,
          shape: const CircleBorder(),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          ),
          child: const Icon(Icons.add, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total gastado',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(fmt.format(state.total),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.error)),
              const SizedBox(height: 16),
              _searchBar(),
              const SizedBox(height: 12),
              _filterRow(state),
              const SizedBox(height: 10),
              _categoryFilterRow(state),
              const SizedBox(height: 8),
              Text('Desliza → para editar, ← para eliminar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
              const SizedBox(height: 12),
              Expanded(child: _buildList(state, fmt)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      onChanged: (v) => ref.read(expensesNotifierProvider.notifier).setSearch(v),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Buscar gasto...',
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          borderSide: const BorderSide(color: AppColors.accentLight),
        ),
      ),
    );
  }

  Widget _filterRow(ExpensesState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip('Todos', state.priorityFilter == 'todos',
              () => ref.read(expensesNotifierProvider.notifier).setPriorityFilter('todos')),
          const SizedBox(width: 8),
          _filterChip('Alta', state.priorityFilter == 'alta',
              () => ref.read(expensesNotifierProvider.notifier).setPriorityFilter('alta')),
          const SizedBox(width: 8),
          _filterChip('Baja', state.priorityFilter == 'baja',
              () => ref.read(expensesNotifierProvider.notifier).setPriorityFilter('baja')),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _showSortSheet(state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_vert, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(_sortLabel(state.sort),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryFilterRow(ExpensesState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip('Todas', state.categoryFilter == 'todas',
              () => ref.read(expensesNotifierProvider.notifier).setCategoryFilter('todas')),
          const SizedBox(width: 8),
          ..._categories.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _filterChip(
                  entry.value['label'] as String,
                  state.categoryFilter == entry.key,
                  () => ref.read(expensesNotifierProvider.notifier).setCategoryFilter(entry.key),
                ),
              )),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 12)),
      ),
    );
  }

  String _sortLabel(ExpenseSort sort) {
    switch (sort) {
      case ExpenseSort.recent: return 'Recientes';
      case ExpenseSort.oldest: return 'Antiguos';
      case ExpenseSort.highest: return 'Mayor monto';
      case ExpenseSort.lowest: return 'Menor monto';
    }
  }

  void _showSortSheet(ExpensesState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            _sortOption(ctx, 'Más recientes', ExpenseSort.recent, state.sort),
            _sortOption(ctx, 'Más antiguos', ExpenseSort.oldest, state.sort),
            _sortOption(ctx, 'Mayor monto', ExpenseSort.highest, state.sort),
            _sortOption(ctx, 'Menor monto', ExpenseSort.lowest, state.sort),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sortOption(BuildContext ctx, String label, ExpenseSort value, ExpenseSort current) {
    final selected = value == current;
    return ListTile(
      title: Text(label,
          style: TextStyle(
              color: selected ? AppColors.accentLight : AppColors.textPrimary, fontSize: 14)),
      trailing: selected ? const Icon(Icons.check, color: AppColors.accentLight, size: 18) : null,
      onTap: () {
        ref.read(expensesNotifierProvider.notifier).setSort(value);
        Navigator.pop(ctx);
      },
    );
  }

  Widget _buildList(ExpensesState state, NumberFormat fmt) {
    if (state.status == ExpensesStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (state.status == ExpensesStatus.error) {
      return Center(
        child: Text(state.errorMessage ?? 'Error',
            style: const TextStyle(color: AppColors.error)),
      );
    }

    final items = state.filtered;

    if (state.expenses.isEmpty) {
      return Center(
        child: Text('Aún no hay gastos',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: Text('No se encontraron gastos con esos filtros',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final e = items[i];
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Dismissible(
            key: ValueKey(e.id),
            background: Container(
              color: AppColors.accent,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.edit, color: AppColors.textPrimary),
            ),
            secondaryBackground: Container(
              color: AppColors.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                if (_canEdit(e.createdAt)) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EditExpensePage(expense: e),
                  ));
                } else {
                  showInfo(context, 'Ya no se puede editar',
                      'Solo puedes editar un gasto durante las primeras 24 horas');
                }
                return false;
              } else {
                return await showConfirmDialog(
                  context,
                  title: '¿Eliminar gasto?',
                  message: 'Esta acción no se puede deshacer.',
                  confirmText: 'Eliminar',
                  isDanger: true,
                );
              }
            },
            onDismissed: (_) {
              ref.read(expensesNotifierProvider.notifier).remove(e.id);
              showSuccess(context, 'Gasto eliminado');
            },
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_categoryIcon(e.category), color: AppColors.accentLight, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(e.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            if (e.priority == 'alta') ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Text('Alta',
                                    style: TextStyle(color: AppColors.accentLight, fontSize: 11)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_categoryLabel(e.category)} · ${DateFormat('dd MMM').format(e.date)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('-${fmt.format(e.amount)}',
                      style: const TextStyle(color: AppColors.error, fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}