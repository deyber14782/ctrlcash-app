import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reports.dart';
import '_fmt.dart';

class CategoryChart extends StatelessWidget {
  final ByCategory byCategory;
  const CategoryChart({super.key, required this.byCategory});

  static const _colors = [
    AppColors.accent,
    Color(0xFF7F77DD),
    Color(0xFF1D9E75),
    Color(0xFFD85A30),
    Color(0xFF378ADD),
    Color(0xFFD4537E),
    Color(0xFFBA7517),
    AppColors.textSecondary,
    Color(0xFF888780),
  ];

  Color _colorFor(int index) => _colors[index % _colors.length];

  @override
  Widget build(BuildContext context) {
    final items = byCategory.items;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gasto por categoría',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '¿En qué se te va el dinero?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Sin datos',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        for (var i = 0; i < items.length; i++)
                          PieChartSectionData(
                            value: items[i].amount,
                            color: _colorFor(i),
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
                      for (var i = 0; i < items.length; i++) ...[
                        _legend(items[i], _colorFor(i)),
                        if (i < items.length - 1) const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _legend(CategoryItem item, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item.label} · ${item.percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(reportFmt.format(item.amount),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}