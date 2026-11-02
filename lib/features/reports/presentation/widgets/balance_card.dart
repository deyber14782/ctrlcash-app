import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/reports.dart';
import '_fmt.dart';

class BalanceCard extends StatelessWidget {
  final Balance balance;
  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final positive = balance.remaining >= 0;
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
          Text('Balance del periodo', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _col(context, 'Ingresos', balance.income, AppColors.success),
              _col(context, 'Gastos', balance.expense, AppColors.error),
              _col(context, 'Queda', balance.remaining,
                  positive ? AppColors.success : AppColors.error),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            positive
                ? 'Te quedó dinero en este periodo. Bien hecho.'
                : 'Gastaste más de lo que ingresó. Revisa tus gastos.',
            style: TextStyle(color: positive ? AppColors.success : AppColors.error, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _col(BuildContext context, String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(reportFmt.format(value),
            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }
}