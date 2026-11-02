import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../providers/income_notifier.dart';
import '../providers/income_state.dart';
import 'add_income_page.dart';
import 'edit_income_page.dart';

class IncomePage extends ConsumerStatefulWidget {
  const IncomePage({super.key});

  @override
  ConsumerState<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends ConsumerState<IncomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incomeNotifierProvider.notifier).load();
    });
  }

  bool _canEdit(DateTime createdAt) {
    return DateTime.now().difference(createdAt).inHours < 24;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incomeNotifierProvider);
    final fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ingresos'),
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
            MaterialPageRoute(builder: (_) => const AddIncomePage()),
          ),
          child: const Icon(Icons.add, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total ingresos',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(fmt.format(state.total),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.success)),
              const SizedBox(height: 16),
              _searchBar(),
              const SizedBox(height: 12),
              _sortRow(state),
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
      onChanged: (v) => ref.read(incomeNotifierProvider.notifier).setSearch(v),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Buscar ingreso...',
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

  Widget _sortRow(IncomeState state) {
    return Row(
      children: [
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
    );
  }

  String _sortLabel(IncomeSort sort) {
    switch (sort) {
      case IncomeSort.recent: return 'Recientes';
      case IncomeSort.oldest: return 'Antiguos';
      case IncomeSort.highest: return 'Mayor monto';
      case IncomeSort.lowest: return 'Menor monto';
    }
  }

  void _showSortSheet(IncomeState state) {
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
            _sortOption(ctx, 'Más recientes', IncomeSort.recent, state.sort),
            _sortOption(ctx, 'Más antiguos', IncomeSort.oldest, state.sort),
            _sortOption(ctx, 'Mayor monto', IncomeSort.highest, state.sort),
            _sortOption(ctx, 'Menor monto', IncomeSort.lowest, state.sort),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sortOption(BuildContext ctx, String label, IncomeSort value, IncomeSort current) {
    final selected = value == current;
    return ListTile(
      title: Text(label,
          style: TextStyle(
              color: selected ? AppColors.accentLight : AppColors.textPrimary, fontSize: 14)),
      trailing: selected ? const Icon(Icons.check, color: AppColors.accentLight, size: 18) : null,
      onTap: () {
        ref.read(incomeNotifierProvider.notifier).setSort(value);
        Navigator.pop(ctx);
      },
    );
  }

  Widget _buildList(IncomeState state, NumberFormat fmt) {
    if (state.status == IncomeStatus.loading) {
      return const Center(
          child: SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)));
    }
    if (state.status == IncomeStatus.error) {
      return Center(
        child: Text(state.errorMessage ?? 'Error',
            style: const TextStyle(color: AppColors.error)),
      );
    }

    final items = state.filtered;

    if (state.incomes.isEmpty) {
      return Center(
        child: Text('Aún no hay ingresos',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: Text('No se encontraron ingresos',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final inc = items[i];
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Dismissible(
            key: ValueKey(inc.id),
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
                if (_canEdit(inc.createdAt)) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EditIncomePage(income: inc),
                  ));
                } else {
                  showInfo(context, 'Ya no se puede editar',
                      'Solo puedes editar un ingreso durante las primeras 24 horas');
                }
                return false;
              } else {
                return await showConfirmDialog(
                  context,
                  title: '¿Eliminar ingreso?',
                  message: 'Esta acción no se puede deshacer.',
                  confirmText: 'Eliminar',
                  isDanger: true,
                );
              }
            },
            onDismissed: (_) {
              ref.read(incomeNotifierProvider.notifier).remove(inc.id);
              showSuccess(context, 'Ingreso eliminado');
            },
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_downward_rounded, color: AppColors.success, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inc.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(DateFormat('dd MMM').format(inc.date),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('+${fmt.format(inc.amount)}',
                      style: const TextStyle(color: AppColors.success, fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}