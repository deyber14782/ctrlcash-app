import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../expenses/presentation/providers/expenses_notifier.dart';
import '../../../income/presentation/providers/income_notifier.dart';
import '../../../../shared/widgets/fade_in.dart';
import '../../../../shared/widgets/tappable_scale.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(authNotifierProvider.notifier).loadProfile();
      final user = ref.read(authNotifierProvider).user;
      if (user != null && !user.profileCompleted && mounted) {
        context.go('/complete-profile');
        return;
      }
      ref.read(expensesNotifierProvider.notifier).load();
      ref.read(incomeNotifierProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    final expensesState = ref.watch(expensesNotifierProvider);
    final incomeState = ref.watch(incomeNotifierProvider);
    final fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);
    final name = state.user?.displayName ?? state.user?.email ?? 'Usuario';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                const SizedBox(height: 12),
                FadeIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola,',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Balance principal — destacado con gradiente de acento
                FadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.accent, AppColors.surfaceElevated],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Balance total',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          fmt.format(incomeState.total - expensesState.total),
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ingresos / Gastos
                FadeIn(
                  delay: const Duration(milliseconds: 220),
                  child: Row(
                    children: [
                      Expanded(
                        child: TappableScale(
                          onTap: () => context.push('/income'),
                          child: _SummaryCard(
                            label: 'Ingresos',
                            value: fmt.format(incomeState.total),
                            valueColor: AppColors.success,
                            icon: Icons.arrow_downward_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TappableScale(
                          onTap: () => context.push('/expenses'),
                          child: _SummaryCard(
                            label: 'Gastos',
                            value: fmt.format(expensesState.total),
                            valueColor: AppColors.error,
                            icon: Icons.arrow_upward_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                FadeIn(
                  delay: const Duration(milliseconds: 240),
                  child: TappableScale(
                    onTap: () => context.push('/savings-goals'),
                    child: _MenuCard(
                      icon: Icons.savings_rounded,
                      title: 'Metas de ahorro',
                      subtitle: 'Aporta hacia tus objetivos',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeIn(
                  delay: const Duration(milliseconds: 260),
                  child: TappableScale(
                    onTap: () => context.push('/budgets'),
                    child: _MenuCard(
                      icon: Icons.pie_chart_rounded,
                      title: 'Presupuestos',
                      subtitle: 'Controla tu límite por categoría',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeIn(
                  delay: const Duration(milliseconds: 280),
                  child: TappableScale(
                    onTap: () => context.push('/debts'),
                    child: _MenuCard(
                      icon: Icons.account_balance_rounded,
                      title: 'Deudas',
                      subtitle: 'Ver y calcular amortización',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: TappableScale(
                    onTap: () => context.push('/reports'),
                    child: _MenuCard(
                      icon: Icons.insights_rounded,
                      title: 'Informes',
                      subtitle: 'Análisis de tus finanzas',
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                FadeIn(
                  delay: const Duration(milliseconds: 340),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Movimientos recientes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            'Aún no hay movimientos',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: valueColor),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.textPrimary, fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accentLight, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}