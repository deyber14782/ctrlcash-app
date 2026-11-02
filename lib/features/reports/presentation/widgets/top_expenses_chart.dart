import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/reports.dart';
import '_fmt.dart';

class TopExpensesChart extends StatelessWidget {
  final List<TopExpense> topExpenses;
  const TopExpensesChart({super.key, required this.topExpenses});

  @override
  Widget build(BuildContext context) {
    final maxAmount = topExpenses.isEmpty
        ? 1.0
        : topExpenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

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
          Text('Mayores gastos',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Lo que más te cuesta',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          const SizedBox(height: 16),
          if (topExpenses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Sin datos',
                  style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            ...topExpenses.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(e.name,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(reportFmt.format(e.amount),
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth * (e.amount / maxAmount);
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 6,
                          width: double.infinity,
                          color: AppColors.border,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 6,
                            width: width,
                            color: e.priority == 'alta' ? AppColors.accentLight : AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}