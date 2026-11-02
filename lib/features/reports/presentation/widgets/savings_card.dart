import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/reports.dart';

class SavingsCard extends StatelessWidget {
  final SavingsRate savings;
  const SavingsCard({super.key, required this.savings});

  @override
  Widget build(BuildContext context) {
    final rate = savings.rate;
    final good = rate >= 10;
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
          Text('Tasa de ahorro', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('${rate.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: good ? AppColors.success : AppColors.error)),
          const SizedBox(height: 4),
          Text(savings.message,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}