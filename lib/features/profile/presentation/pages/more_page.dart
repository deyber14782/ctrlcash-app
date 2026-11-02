import 'package:ctrlcashapp/features/profile/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

    final name = user?.displayName ?? 'Usuario';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    String frecuencia = '—';
    switch (user?.paymentFrequency) {
      case 'semanal':
        frecuencia = 'Semanal';
        break;
      case 'quincenal':
        frecuencia = 'Quincenal';
        break;
      case 'mensual':
        frecuencia = 'Mensual';
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
          children: [
            const SizedBox(height: 8),
            Text('Perfil', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 24),

            // Tarjeta de identidad
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.surfaceElevated],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary.withValues(alpha: 0.75)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Datos financieros
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datos financieros',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  _infoRow('Edad', user?.age != null ? '${user!.age} años' : '—'),
                  _infoRow('Frecuencia de pago', frecuencia),
                  _infoRow(
                    'Pago',
                    user?.paymentAmount != null
                        ? fmt.format(user!.paymentAmount)
                        : '—',
                  ),
                  if (user?.role == 'administrador') _infoRow('Rol', 'Administrador'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Opciones
            _menuTile(context, Icons.savings_rounded, 'Metas de ahorro', () {
              context.push('/savings-goals');
            }),
            const SizedBox(height: 10),
            _menuTile(context, Icons.pie_chart_rounded, 'Presupuestos', () {
              context.push('/budgets');
            }),
            const SizedBox(height: 10),
            _menuTile(context, Icons.account_balance_rounded, 'Deudas', () {
              context.push('/debts');
            }),
            const SizedBox(height: 10),
            _menuTile(context, Icons.insights_rounded, 'Informes', () {
              context.push('/reports');
            }),
            const SizedBox(height: 10),
            _menuTile(
              context,
              Icons.notifications_rounded,
              'Notificaciones',
              () {
                context.push('/notifications');
              },
            ),
            const SizedBox(height: 10),
            _menuTile(context, Icons.settings_rounded, 'Configuración', () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            }),

            const SizedBox(height: 24),

            // Cerrar sesión
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go('/welcome');
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'CERRAR SESIÓN',
                style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.accentLight, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}