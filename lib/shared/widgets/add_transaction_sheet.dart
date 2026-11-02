import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

void showAddTransactionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('¿Qué quieres registrar?',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 20),
              _option(ctx, Icons.arrow_downward, 'Nuevo ingreso',
                  AppColors.accent, () {
                Navigator.pop(ctx);
                ctx.push('/add-income');
              }),
              const SizedBox(height: 12),
              _option(ctx, Icons.arrow_upward, 'Nuevo gasto',
                  AppColors.error, () {
                Navigator.pop(ctx);
                ctx.push('/add-expense');
              }),
            ],
          ),
        ),
      );
    },
  );
}

Widget _option(BuildContext ctx, IconData icon, String label, Color iconColor,
    VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Text(label, style: Theme.of(ctx).textTheme.bodyLarge),
        ],
      ),
    ),
  );
}