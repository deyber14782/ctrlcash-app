import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/reports.dart';
import '_fmt.dart';

class PriorityChart extends StatelessWidget {
  final ByPriority byPriority;
  const PriorityChart({super.key, required this.byPriority});

  @override
  Widget build(BuildContext context) {
    final total = byPriority.alta + byPriority.baja;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución por prioridad',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '¿Gastas en lo importante o en lo prescindible?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (total == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Sin datos',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        PieChartSectionData(
                          value: byPriority.alta,
                          color: AppColors.accentLight,
                          title: '',
                          radius: 24,
                        ),
                        PieChartSectionData(
                          value: byPriority.baja,
                          color: AppColors.textSecondary,
                          title: '',
                          radius: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legend('Prioridad alta', byPriority.alta,
                          byPriority.altaPct, AppColors.accentLight),
                      const SizedBox(height: 12),
                      _legend('Prioridad baja', byPriority.baja,
                          byPriority.bajaPct, AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          if (total > 0)
            Text(
              byPriority.bajaPct > 50
                  ? 'Más de la mitad de tus gastos son de prioridad baja. Ahí hay margen para recortar.'
                  : 'La mayoría de tus gastos son prioritarios. Buen control.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _legend(String label, double value, double pct, Color color) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label · ${pct.toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(reportFmt.format(value),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}