import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../shared/widgets/add_transaction_sheet.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAssistant = navigationShell.currentIndex == 2;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isAssistant
          ? null
          : Container(
              height: 58,
              width: 58,
              margin: EdgeInsets.only(top: 8, bottom: bottomInset),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.55),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: AppColors.accent,
                elevation: 0,
                shape: const CircleBorder(),
                onPressed: () => showAddTransactionSheet(context),
                child: const Icon(Icons.add, color: AppColors.textPrimary, size: 30),
              ),
            ),
      bottomNavigationBar: _BottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        bottomInset: bottomInset,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double bottomInset;
  const _BottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Row(
          children: [
            _item(0, Icons.home_outlined, 'Inicio'),
            _item(1, Icons.bar_chart_outlined, 'Finanzas'),
            const SizedBox(width: 56), // hueco para el FAB central
            _item(2, Icons.smart_toy_outlined, 'Asistente'),
            _item(3, Icons.menu, 'Más'),
          ],
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final selected = currentIndex == index;
    final color = selected ? AppColors.accentLight : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}