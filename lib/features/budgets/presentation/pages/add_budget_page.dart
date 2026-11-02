import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../providers/budgets_notifier.dart';

class AddBudgetPage extends ConsumerStatefulWidget {
  const AddBudgetPage({super.key});

  @override
  ConsumerState<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends ConsumerState<AddBudgetPage> {
  final amountCtrl = TextEditingController();
  String category = 'comida';
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
    if (amount <= 0) {
      showError(context, 'Ingresa un monto válido');
      return;
    }

    setState(() => saving = true);
    try {
      final error = await ref.read(budgetsNotifierProvider.notifier).add(
            category: category,
            amount: amount,
          );
      if (!mounted) return;
      if (error == null) {
        showSuccess(context, 'Presupuesto creado');
        Navigator.of(context).pop();
      } else if (error.contains('DUPLICATE_CATEGORY') || error.contains('ya tienes')) {
        showError(context, 'Ya existe un presupuesto para esta categoría');
      } else {
        showError(context, 'No se pudo crear el presupuesto');
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
        title: const Text('Nuevo presupuesto'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 24),
              AppTextField(
                controller: amountCtrl,
                label: 'Límite mensual',
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
              ),
              const SizedBox(height: 8),
              Text(
                'Se reinicia automáticamente cada mes.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: Text(
                  saving ? 'GUARDANDO...' : 'CREAR PRESUPUESTO',
                  style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}