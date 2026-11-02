import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../reports/presentation/providers/reports_notifier.dart';
import '../../../reports/presentation/providers/reports_state.dart';
import '../../../debts/presentation/providers/debts_notifier.dart';
import '../../../debts/presentation/providers/debts_state.dart';

// Un aviso generado
class _Notice {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String? route; // a dónde ir al tocar (opcional)

  const _Notice({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.route,
  });
}

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportsNotifierProvider.notifier).loadPeriod('all');
      ref.read(debtsNotifierProvider.notifier).load();
    });
  }

  List<_Notice> _buildNotices(ReportsState reports, DebtsState debts) {
    final notices = <_Notice>[];
    final fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);
    final r = reports.reports;

    if (r != null) {
      // Balance negativo
      if (r.balance.remaining < 0) {
        notices.add(_Notice(
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
          title: 'Tus gastos superan tus ingresos',
          message:
              'Este periodo gastaste ${fmt.format(r.balance.expense)} de ${fmt.format(r.balance.income)}. Revisa tus gastos.',
          route: '/reports',
        ));
      }

      // Tasa de ahorro baja
      if (r.balance.income > 0 && r.savingsRate.rate < 10) {
        notices.add(_Notice(
          icon: Icons.savings_rounded,
          color: AppColors.warning,
          title: 'Tu tasa de ahorro es baja',
          message:
              'Estás ahorrando ${r.savingsRate.rate.toStringAsFixed(0)}%. Intenta apartar al menos el 10% de tus ingresos.',
          route: '/reports',
        ));
      }

      // Gastos hormiga
      if (r.antExpenses.total > 0) {
        notices.add(_Notice(
          icon: Icons.bug_report_rounded,
          color: AppColors.accentLight,
          title: 'Gastos hormiga detectados',
          message:
              'Acumulaste ${fmt.format(r.antExpenses.total)} en pequeños gastos repetidos. Míralos en tus informes.',
          route: '/reports',
        ));
      }

      // Gastos vampiro
      if (r.vampireExpenses.total > 0) {
        notices.add(_Notice(
          icon: Icons.bloodtype_rounded,
          color: AppColors.error,
          title: 'Gastos vampiro detectados',
          message:
              'Tienes ${fmt.format(r.vampireExpenses.total)} en gastos recurrentes que drenan tu dinero.',
          route: '/reports',
        ));
      }
    }

    // Deudas
    if (debts.debts.isNotEmpty) {
      notices.add(_Notice(
        icon: Icons.account_balance_rounded,
        color: AppColors.accentLight,
        title: 'Tienes deudas activas',
        message:
            'Debes ${fmt.format(debts.totalDebt)} en total. Revisa tu plan de pago.',
        route: '/debts',
      ));
    }

    return notices;
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportsNotifierProvider);
    final debts = ref.watch(debtsNotifierProvider);

    final loading = reports.status == ReportsStatus.loading ||
        debts.status == DebtsStatus.loading;

    final notices = _buildNotices(reports, debts);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: loading
            ? const Center(
                child: SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)))
            : notices.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: notices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _noticeCard(notices[i]),
                  ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.background, size: 30),
            ),
            const SizedBox(height: 20),
            Text('Todo en orden',
                style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('No tienes avisos por ahora. Sigue registrando tus finanzas.',
                style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _noticeCard(_Notice notice) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: notice.route != null ? () => context.push(notice.route!) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notice.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notice.icon, color: notice.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notice.title,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(notice.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4)),
                ],
              ),
            ),
            if (notice.route != null)
              const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}