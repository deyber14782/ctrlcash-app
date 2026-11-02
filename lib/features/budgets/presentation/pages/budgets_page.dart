import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../domain/entities/budget.dart';
import '../providers/budgets_notifier.dart';
import '../providers/budgets_state.dart';
import 'add_budget_page.dart';

class BudgetsPage extends ConsumerStatefulWidget {
  const BudgetsPage({super.key});

  @override
  ConsumerState<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends ConsumerState<BudgetsPage> {
  static const _categoryInfo = {
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
      ref.read(budgetsNotifierProvider.notifier).load();
    });
  }

  String _label(String category) =>
      _categoryInfo[category]?['label'] as String? ?? 'Otros';

  IconData _icon(String category) =>
      _categoryInfo[category]?['icon'] as IconData? ?? Icons.category_outlined;

  Color _statusColor(String status) {
    switch (status) {
      case 'over':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetsNotifierProvider);
    final fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Presupuestos'),
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
            MaterialPageRoute(builder: (_) => const AddBudgetPage()),
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
              Text(
                'Presupuestos mensuales',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Se reinician automáticamente cada mes',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildList(state, fmt)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BudgetsState state, NumberFormat fmt) {
    if (state.status == BudgetsStatus.loading) {
      return const Center(
          child: SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)));
    }
    if (state.status == BudgetsStatus.error) {
      return Center(
        child: Text(state.errorMessage ?? 'Error',
            style: const TextStyle(color: AppColors.error)),
      );
    }
    if (state.budgets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pie_chart_outline, color: AppColors.textSecondary, size: 40),
              const SizedBox(height: 16),
              Text('Sin presupuestos aún',
                  style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Crea un límite mensual por categoría para controlar tus gastos.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: state.budgets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _budgetCard(state.budgets[i], fmt),
    );
  }

  Widget _budgetCard(Budget b, NumberFormat fmt) {
    final color = _statusColor(b.status);
    final progress = (b.percentage / 100).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: Dismissible(
        key: ValueKey(b.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (_) async {
          return await showConfirmDialog(
            context,
            title: '¿Eliminar presupuesto?',
            message: 'Dejarás de trackear el límite de esta categoría.',
            confirmText: 'Eliminar',
            isDanger: true,
          );
        },
        onDismissed: (_) {
          ref.read(budgetsNotifierProvider.notifier).remove(b.id);
          showSuccess(context, 'Presupuesto eliminado');
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_icon(b.category), color: color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_label(b.category),
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  Text('${b.percentage}%',
                      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${fmt.format(b.spent)} de ${fmt.format(b.amount)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  if (b.status == 'over')
                    const Text('Excedido',
                        style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w500))
                  else if (b.status == 'warning')
                    Text('Cerca del límite',
                        style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}