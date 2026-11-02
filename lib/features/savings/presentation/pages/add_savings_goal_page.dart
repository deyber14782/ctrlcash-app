import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../providers/savings_notifier.dart';

class AddSavingsGoalPage extends ConsumerStatefulWidget {
  const AddSavingsGoalPage({super.key});

  @override
  ConsumerState<AddSavingsGoalPage> createState() => _AddSavingsGoalPageState();
}

class _AddSavingsGoalPageState extends ConsumerState<AddSavingsGoalPage> {
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  DateTime? deadline;
  bool saving = false;

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month + 1, now.day),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accentLight,
            surface: AppColors.surface,
            onPrimary: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => deadline = picked);
  }

  Future<void> _save() async {
    if (saving) return;
    final amount = CurrencyInputFormatter.parse(amountCtrl.text);
    if (nameCtrl.text.trim().isEmpty) {
      showError(context, 'Ingresa un nombre para tu meta');
      return;
    }
    if (amount <= 0) {
      showError(context, 'Ingresa un monto objetivo válido');
      return;
    }

    setState(() => saving = true);
    try {
      final error = await ref.read(savingsNotifierProvider.notifier).add(
            name: nameCtrl.text.trim(),
            targetAmount: amount,
            deadline: deadline,
          );
      if (!mounted) return;
      if (error == null) {
        showSuccess(context, 'Meta creada');
        Navigator.of(context).pop();
      } else {
        showError(context, 'No se pudo crear la meta');
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
        title: const Text('Nueva meta de ahorro'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(controller: nameCtrl, label: 'Nombre de la meta'),
              const SizedBox(height: 20),
              AppTextField(
                controller: amountCtrl,
                label: 'Monto objetivo',
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
              ),
              const SizedBox(height: 20),
              Text('Fecha límite (opcional)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        deadline != null
                            ? '${deadline!.day}/${deadline!.month}/${deadline!.year}'
                            : 'Sin fecha límite',
                        style: TextStyle(
                          color: deadline != null ? AppColors.textPrimary : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (deadline != null)
                        GestureDetector(
                          onTap: () => setState(() => deadline = null),
                          child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: Text(
                  saving ? 'CREANDO...' : 'CREAR META',
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