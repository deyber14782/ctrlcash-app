import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../providers/debts_notifier.dart';

class AddDebtPage extends ConsumerStatefulWidget {
  const AddDebtPage({super.key});

  @override
  ConsumerState<AddDebtPage> createState() => _AddDebtPageState();
}

class _AddDebtPageState extends ConsumerState<AddDebtPage> {
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final rateCtrl = TextEditingController();
  final installmentsCtrl = TextEditingController();
  bool saving = false;

  Future<void> _save() async {
    if (saving) return;

    final amount = CurrencyInputFormatter.parse(amountCtrl.text);
    final rate = double.tryParse(rateCtrl.text.trim().replaceAll(',', '.'));
    final installments = int.tryParse(installmentsCtrl.text.trim());

    if (nameCtrl.text.trim().isEmpty) {
      showError(context, 'Ingresa un nombre');
      return;
    }
    if (amount <= 0) {
      showError(context, 'Ingresa un monto válido');
      return;
    }
    if (rate == null || rate < 0) {
      showError(context, 'Ingresa una tasa válida');
      return;
    }
    if (installments == null || installments <= 0) {
      showError(context, 'Ingresa un número de cuotas válido');
      return;
    }

    setState(() => saving = true);
    try {
      final ok = await ref
          .read(debtsNotifierProvider.notifier)
          .add(
            name: nameCtrl.text.trim(),
            amount: amount,
            interestRate: rate,
            installments: installments,
          );
      if (!mounted) return;
      if (ok) {
        showSuccess(context, 'Deuda guardada');
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
        title: const Text('Nueva deuda'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            AppTextField(controller: nameCtrl, label: 'Nombre de la deuda'),
            const SizedBox(height: 20),
            AppTextField(
              controller: amountCtrl,
              label: 'Monto total',
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: rateCtrl,
              label: 'Tasa de interés mensual (%)',
              hint: 'Ej: 2',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: installmentsCtrl,
              label: 'Número de cuotas',
              hint: 'Ej: 12',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: saving ? null : _save,
              child: Text(
                saving ? 'GUARDANDO...' : 'CALCULAR Y GUARDAR',
                style: const TextStyle(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}