import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/reports_notifier.dart';
import '../providers/reports_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/savings_card.dart';
import '../widgets/priority_chart.dart';
import '../widgets/category_chart.dart';
import '../widgets/top_expenses_chart.dart';
import '../widgets/timeline_chart.dart';
import '../widgets/grouped_card.dart';
import '../widgets/_fmt.dart';
import '../export/reports_exporter.dart';
import 'report_detail_page.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportsNotifierProvider.notifier).loadPeriod('all');
    });
  }

  void _showExportSheet() {
    final state = ref.read(reportsNotifierProvider);
    final reports = state.reports;
    if (reports == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay informe que exportar todavía')),
      );
      return;
    }

    final periodLabel = _periodLabel(state);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Exportar informe', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 20),
              _exportOption(ctx, Icons.picture_as_pdf_outlined, 'PDF', () {
                Navigator.pop(ctx);
                ReportsExporter.exportPdf(reports, periodLabel);
              }),
              const SizedBox(height: 12),
              _exportOption(ctx, Icons.table_chart_outlined, 'Excel', () {
                Navigator.pop(ctx);
                ReportsExporter.exportExcel(reports, periodLabel);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exportOption(BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentLight, size: 22),
            const SizedBox(width: 14),
            Text(label, style: Theme.of(ctx).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  String _periodLabel(ReportsState state) {
    switch (state.period) {
      case 'month':
        return 'Este mes';
      case '3months':
        return 'Últimos 3 meses';
      case 'custom':
        if (state.from != null && state.to != null) {
          final f = DateFormat('dd/MM/yyyy');
          return '${f.format(state.from!)} - ${f.format(state.to!)}';
        }
        return 'Personalizado';
      default:
        return 'Todo el historial';
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accentLight,
            surface: AppColors.surface,
            onPrimary: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      ref.read(reportsNotifierProvider.notifier).loadRange(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Informes'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: AppColors.textPrimary),
            onPressed: () => _showExportSheet(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _periodSelector(state),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _periodSelector(ReportsState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _periodChip('Todo', 'all', state),
          const SizedBox(width: 8),
          _periodChip('Mes', 'month', state),
          const SizedBox(width: 8),
          _periodChip('3 meses', '3months', state),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _pickRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: state.period == 'custom' ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: state.period == 'custom' ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 13,
                      color: state.period == 'custom' ? AppColors.textPrimary : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    state.period == 'custom' && state.from != null
                        ? '${DateFormat('dd/MM').format(state.from!)}-${DateFormat('dd/MM').format(state.to!)}'
                        : 'Personalizado',
                    style: TextStyle(
                      color: state.period == 'custom' ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodChip(String label, String value, ReportsState state) {
    final selected = state.period == value;
    return GestureDetector(
      onTap: () => ref.read(reportsNotifierProvider.notifier).loadPeriod(value),
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

  Widget _buildBody(ReportsState state) {
    if (state.status == ReportsStatus.loading) {
      return const Center(
        child: SizedBox(
          width: 28, height: 28,
          child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
        ),
      );
    }
    if (state.status == ReportsStatus.error) {
      return Center(
        child: Text(state.errorMessage ?? 'Error',
            style: const TextStyle(color: AppColors.error)),
      );
    }
    final r = state.reports;
    if (r == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ReportDetailPage(
              type: 'balance',
              title: 'Balance del periodo',
              subtitle: 'Análisis de tus ingresos frente a tus gastos',
              dataSection: _balanceDataSection(r.balance),
            ),
          )),
          child: BalanceCard(balance: r.balance),
        ),
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ReportDetailPage(
              type: 'savings',
              title: 'Tasa de ahorro',
              subtitle: 'Análisis de cuánto logras ahorrar',
              dataSection: _savingsDataSection(r.savingsRate),
            ),
          )),
          child: SavingsCard(savings: r.savingsRate),
        ),
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ReportDetailPage(
              type: 'priority',
              title: 'Distribución por prioridad',
              subtitle: 'Análisis de en qué priorizas tu dinero',
              dataSection: _priorityDataSection(r.byPriority),
            ),
          )),
          child: PriorityChart(byPriority: r.byPriority),
        ),
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ReportDetailPage(
              type: 'category',
              title: 'Gasto por categoría',
              subtitle: 'Análisis de en qué se te va el dinero',
              dataSection: _categoryDataSection(r.byCategory),
            ),
          )),
          child: CategoryChart(byCategory: r.byCategory),
        ),
        const SizedBox(height: 14),
        TopExpensesChart(topExpenses: r.topExpenses),
        const SizedBox(height: 14),
        if (r.overTime.isNotEmpty) ...[
          TimelineChart(points: r.overTime, title: 'Gasto en el tiempo'),
          const SizedBox(height: 14),
        ],
        GroupedCard(
          report: r.antExpenses,
          title: 'Gastos hormiga',
          subtitle: 'Pequeños y repetidos que suman sin que lo notes',
          icon: Icons.bug_report_outlined,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReportDetailPage(
                type: 'ant',
                title: 'Gastos hormiga',
                subtitle: 'Análisis detallado de tus gastos pequeños y repetidos',
                dataSection: _groupedDataSection(r.antExpenses),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        GroupedCard(
          report: r.vampireExpenses,
          title: 'Gastos vampiro',
          subtitle: 'Recurrentes que drenan tu dinero constantemente',
          icon: Icons.bloodtype_outlined,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReportDetailPage(
                type: 'vampire',
                title: 'Gastos vampiro',
                subtitle: 'Análisis detallado de tus gastos recurrentes',
                dataSection: _groupedDataSection(r.vampireExpenses),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _balanceDataSection(dynamic balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dataRow('Ingresos', reportFmt.format(balance.income), AppColors.success),
        const SizedBox(height: 12),
        _dataRow('Gastos', reportFmt.format(balance.expense), AppColors.error),
        const SizedBox(height: 12),
        _dataRow('Te queda', reportFmt.format(balance.remaining),
            balance.remaining >= 0 ? AppColors.success : AppColors.error),
      ],
    );
  }

  Widget _savingsDataSection(dynamic savings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tu tasa de ahorro',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text('${savings.rate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: AppColors.accentLight, fontSize: 28, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(savings.message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _priorityDataSection(dynamic bp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dataRow('Prioridad alta',
            '${reportFmt.format(bp.alta)} (${bp.altaPct.toStringAsFixed(0)}%)', AppColors.accentLight),
        const SizedBox(height: 12),
        _dataRow('Prioridad baja',
            '${reportFmt.format(bp.baja)} (${bp.bajaPct.toStringAsFixed(0)}%)', AppColors.textSecondary),
      ],
    );
  }

  Widget _categoryDataSection(dynamic byCategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total gastado',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text(reportFmt.format(byCategory.total),
                  style: const TextStyle(
                      color: AppColors.accentLight, fontSize: 26, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (byCategory.items.isEmpty)
          const Text('No hay gastos registrados en este periodo.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
        else
          ...byCategory.items.map<Widget>((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _dataRow(
                  '${item.label} (${item.percentage.toStringAsFixed(0)}%)',
                  reportFmt.format(item.amount),
                  AppColors.textPrimary,
                ),
              )),
      ],
    );
  }

  Widget _dataRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _groupedDataSection(dynamic report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total acumulado',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text(reportFmt.format(report.total),
                  style: const TextStyle(
                      color: AppColors.accentLight, fontSize: 26, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (report.items.isEmpty)
          const Text('No se detectaron gastos de este tipo.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
        else
          ...report.items.map<Widget>((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      Text('${item.occurrences} veces · promedio ${reportFmt.format(item.average ?? 0)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Text(reportFmt.format(item.total),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              ],
            ),
          )),
      ],
    );
  }
}