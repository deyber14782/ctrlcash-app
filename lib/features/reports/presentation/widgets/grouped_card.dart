import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/reports.dart';
import '_fmt.dart';

class GroupedCard extends StatelessWidget {
  final GroupedReport report;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  const GroupedCard({
    super.key,
    required this.report,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppColors.border),
        ),
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
                  child: Icon(icon, color: AppColors.accentLight, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
            const SizedBox(height: 16),

            if (report.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No se detectaron gastos de este tipo. ¡Bien!',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              )
            else ...[
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
                    const Text('Total que te están costando',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(reportFmt.format(report.total),
                        style: const TextStyle(
                            color: AppColors.accentLight, fontSize: 24, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...report.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                          Text('${item.occurrences} veces',
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
          ],
        ),
      ),
    );
  }
}