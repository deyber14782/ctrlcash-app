import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_notifier.dart';
import '../providers/savings_state.dart';
import 'add_savings_goal_page.dart';

class SavingsGoalsPage extends ConsumerStatefulWidget {
  const SavingsGoalsPage({super.key});

  @override
  ConsumerState<SavingsGoalsPage> createState() => _SavingsGoalsPageState();
}

class _SavingsGoalsPageState extends ConsumerState<SavingsGoalsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savingsNotifierProvider.notifier).load();
    });
  }

  Future<void> _showContributeSheet(SavingsGoal goal) async {
    final ctrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: 24 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Aportar a "${goal.name}"', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 20),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: const BorderSide(color: AppColors.accentLight),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final amount = CurrencyInputFormatter.parse(ctrl.text);
                if (amount <= 0) {
                  showError(context, 'Ingresa un monto válido');
                  return;
                }
                Navigator.pop(ctx);
                final error = await ref.read(savingsNotifierProvider.notifier)
                    .contribute(id: goal.id, amount: amount);
                if (!mounted) return;
                if (error == null) {
                  showSuccess(context, 'Aporte registrado');
                } else {
                  showError(context, 'No se pudo registrar el aporte');
                }
              },
              child: const Text('APORTAR',
                  style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsNotifierProvider);
    final fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Metas de ahorro'),
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
            MaterialPageRoute(builder: (_) => const AddSavingsGoalPage()),
          ),
          child: const Icon(Icons.add, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildList(state, fmt),
        ),
      ),
    );
  }

  Widget _buildList(SavingsState state, NumberFormat fmt) {
    if (state.status == SavingsStatus.loading) {
      return const Center(
          child: SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)));
    }
    if (state.status == SavingsStatus.error) {
      return Center(
        child: Text(state.errorMessage ?? 'Error',
            style: const TextStyle(color: AppColors.error)),
      );
    }
    if (state.goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.savings_outlined, color: AppColors.textSecondary, size: 40),
              const SizedBox(height: 16),
              Text('Sin metas aún',
                  style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Crea una meta y empieza a aportar hacia tus objetivos.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: state.goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _goalCard(state.goals[i], fmt),
    );
  }

  Widget _goalCard(SavingsGoal goal, NumberFormat fmt) {
    final progress = (goal.percentage / 100).clamp(0.0, 1.0);
    final color = goal.completed ? AppColors.success : AppColors.accentLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: Dismissible(
        key: ValueKey(goal.id),
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
            title: '¿Eliminar meta?',
            message: 'Se perderá el historial de aportes de esta meta.',
            confirmText: 'Eliminar',
            isDanger: true,
          );
        },
        onDismissed: (_) {
          ref.read(savingsNotifierProvider.notifier).remove(goal.id);
          showSuccess(context, 'Meta eliminada');
        },
        child: InkWell(
          onTap: goal.completed ? null : () => _showContributeSheet(goal),
          child: Container(
            padding: const EdgeInsets.all(18),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(goal.name, style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    if (goal.completed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text('Completada',
                            style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w500)),
                      )
                    else
                      Text('${goal.percentage}%',
                          style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                if (goal.deadline != null) ...[
                  const SizedBox(height: 4),
                  Text('Fecha límite: ${DateFormat('dd MMM yyyy').format(goal.deadline!)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
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
                    Text('${fmt.format(goal.currentAmount)} de ${fmt.format(goal.targetAmount)}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    if (!goal.completed)
                      const Text('Toca para aportar',
                          style: TextStyle(color: AppColors.accentLight, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}