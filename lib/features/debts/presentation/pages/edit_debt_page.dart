import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../../../../core/errors/error_messages.dart';
import '../../domain/entities/debt.dart';
import '../providers/debts_notifier.dart';

class EditDebtPage extends ConsumerStatefulWidget {
  final Debt debt;
  const EditDebtPage({super.key, required this.debt});

  @override
  ConsumerState<EditDebtPage> createState() => _EditDebtPageState();
}

class _EditDebtPageState extends ConsumerState<EditDebtPage> {
  late final TextEditingController nameCtrl;
  late final TextEditingController amountCtrl;
  late final TextEditingController rateCtrl;
  late final TextEditingController installmentsCtrl;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.debt.name);
    amountCtrl = TextEditingController(text: widget.debt.amount.toStringAsFixed(0));
    rateCtrl = TextEditingController(text: widget.debt.interestRate.toString());
    installmentsCtrl = TextEditingController(text: widget.debt.installments.toString());
  }

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
      final error = await ref.read(debtsNotifierProvider.notifier).update(
            id: widget.debt.id,
            name: nameCtrl.text.trim(),
            amount: amount,
            interestRate: rate,
            installments: installments,
          );
      if (!mounted) return;
      if (error == null) {
        showSuccess(context, 'Deuda actualizada', 'La amortización se recalculó');
        Navigator.of(context).pop();
      } else {
        showError(context, humanizeError(error));
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
        title: const Text('Editar deuda'),
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
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: installmentsCtrl,
              label: 'Número de cuotas',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: saving ? null : _save,
              child: Text(saving ? 'GUARDANDO...' : 'GUARDAR CAMBIOS',
                  style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}