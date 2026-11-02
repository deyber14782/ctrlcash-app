import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/fade_in.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../providers/debts_notifier.dart';
import '../providers/debts_state.dart';
import 'add_debt_page.dart';
import 'edit_debt_page.dart';
import 'amortization_page.dart';

class DebtsPage extends ConsumerStatefulWidget {
  const DebtsPage({super.key});

  @override
  ConsumerState<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends ConsumerState<DebtsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(debtsNotifierProvider.notifier).load();
    });
  }

  bool _canEdit(DateTime createdAt) {
    return DateTime.now().difference(createdAt).inHours < 24;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(debtsNotifierProvider);
    final fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Deudas'),
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
            MaterialPageRoute(builder: (_) => const AddDebtPage()),
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
              Text('Total adeudado',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(fmt.format(state.totalDebt),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.error)),
              const SizedBox(height: 16),
              _searchBar(),
              const SizedBox(height: 12),
              _sortRow(state),
              const SizedBox(height: 8),
              Text('Toca para amortización · desliza → editar, ← eliminar',
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
      onChanged: (v) => ref.read(debtsNotifierProvider.notifier).setSearch(v),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Buscar deuda...',
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

  Widget _sortRow(DebtsState state) {
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

  String _sortLabel(DebtSort sort) {
    switch (sort) {
      case DebtSort.recent: return 'Recientes';
      case DebtSort.highestAmount: return 'Mayor monto';
      case DebtSort.lowestAmount: return 'Menor monto';
      case DebtSort.mostInstallments: return 'Más cuotas';
    }
  }

  void _showSortSheet(DebtsState state) {
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
            _sortOption(ctx, 'Más recientes', DebtSort.recent, state.sort),
            _sortOption(ctx, 'Mayor monto', DebtSort.highestAmount, state.sort),
            _sortOption(ctx, 'Menor monto', DebtSort.lowestAmount, state.sort),
            _sortOption(ctx, 'Más cuotas', DebtSort.mostInstallments, state.sort),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sortOption(BuildContext ctx, String label, DebtSort value, DebtSort current) {
    final selected = value == current;
    return ListTile(
      title: Text(label,
          style: TextStyle(
              color: selected ? AppColors.accentLight : AppColors.textPrimary, fontSize: 14)),
      trailing: selected ? const Icon(Icons.check, color: AppColors.accentLight, size: 18) : null,
      onTap: () {
        ref.read(debtsNotifierProvider.notifier).setSort(value);
        Navigator.pop(ctx);
      },
    );
  }

  Widget _buildList(DebtsState state, NumberFormat fmt) {
    if (state.status == DebtsStatus.loading) {
      return const Center(
          child: SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)));
    }
    if (state.status == DebtsStatus.error) {
      return Center(
        child: Text(state.errorMessage ?? 'Error',
            style: const TextStyle(color: AppColors.error)),
      );
    }

    final items = state.filtered;

    if (state.debts.isEmpty) {
      return Center(
        child: Text('Aún no tienes deudas registradas',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: Text('No se encontraron deudas',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final d = items[i];
        return FadeIn(
          delay: Duration(milliseconds: 40 * i),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: Dismissible(
              key: ValueKey(d.id),
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
                  if (_canEdit(d.createdAt)) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => EditDebtPage(debt: d),
                    ));
                  } else {
                    showInfo(context, 'Ya no se puede editar',
                        'Solo puedes editar una deuda durante las primeras 24 horas');
                  }
                  return false;
                } else {
                  return await showConfirmDialog(
                    context,
                    title: '¿Eliminar deuda?',
                    message: 'Se eliminará la deuda y su tabla de amortización. Esta acción no se puede deshacer.',
                    confirmText: 'Eliminar',
                    isDanger: true,
                  );
                }
              },
              onDismissed: (_) {
                ref.read(debtsNotifierProvider.notifier).remove(d.id);
                showSuccess(context, 'Deuda eliminada');
              },
              child: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AmortizationPage(debtId: d.id, debtName: d.name),
                )),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.account_balance_rounded,
                            color: AppColors.accentLight, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.name,
                                style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 4),
                            Text(
                              '${d.installments} cuotas · ${d.interestRate}% mensual',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(fmt.format(d.amount),
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textSecondary, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}