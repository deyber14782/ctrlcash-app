import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../providers/expenses_notifier.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String priority = 'baja';
  String category = 'otros';
  bool saving = false;

  static const _categories = [
    {'value': 'comida', 'label': 'Comida', 'icon': Icons.restaurant},
    {'value': 'transporte', 'label': 'Transporte', 'icon': Icons.directions_bus},
    {'value': 'vivienda', 'label': 'Vivienda', 'icon': Icons.home_outlined},
    {'value': 'entretenimiento', 'label': 'Entretenimiento', 'icon': Icons.movie_outlined},
    {'value': 'salud', 'label': 'Salud', 'icon': Icons.local_hospital_outlined},
    {'value': 'educacion', 'label': 'Educación', 'icon': Icons.school_outlined},
    {'value': 'ropa', 'label': 'Ropa', 'icon': Icons.checkroom_outlined},
    {'value': 'servicios', 'label': 'Servicios', 'icon': Icons.receipt_long_outlined},
    {'value': 'otros', 'label': 'Otros', 'icon': Icons.category_outlined},
  ];

  Future<void> _save() async {
    if (saving) return;

    final amount = CurrencyInputFormatter.parse(amountCtrl.text);
    if (amount <= 0 || nameCtrl.text.trim().isEmpty) {
      showError(context, 'Datos incompletos', 'Ingresa un nombre y un monto válido');
      return;
    }

    setState(() => saving = true);
    try {
      final ok = await ref.read(expensesNotifierProvider.notifier).add(
            amount: amount,
            name: nameCtrl.text.trim(),
            priority: priority,
            category: category,
          );

      if (!mounted) return;
      if (ok) {
        showSuccess(context, 'Gasto guardado');
        Navigator.of(context).pop();
      } else {
        showError(context, 'No se pudo guardar', 'Revisa tu conexión e inténtalo de nuevo');
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nuevo gasto'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(controller: nameCtrl, label: 'Nombre del gasto'),
              const SizedBox(height: 20),
              AppTextField(
                controller: amountCtrl,
                label: 'Monto',
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
              ),
              const SizedBox(height: 22),
              Text('Prioridad',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _priorityChip('alta', 'Alta'),
                  const SizedBox(width: 12),
                  _priorityChip('baja', 'Baja'),
                ],
              ),
              const SizedBox(height: 22),
              Text('Categoría',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((c) {
                  final selected = category == c['value'];
                  return GestureDetector(
                    onTap: () => setState(() => category = c['value'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accent : AppColors.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: selected ? AppColors.accent : AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c['icon'] as IconData,
                              size: 16,
                              color: selected ? AppColors.textPrimary : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(c['label'] as String,
                              style: TextStyle(
                                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: Text(
                  saving ? 'GUARDANDO...' : 'GUARDAR GASTO',
                  style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(String value, String label) {
    final selected = priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => priority = value),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}