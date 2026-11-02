import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../../../../core/errors/error_messages.dart';
import '../../domain/entities/income.dart';
import '../providers/income_notifier.dart';

class EditIncomePage extends ConsumerStatefulWidget {
  final Income income;
  const EditIncomePage({super.key, required this.income});

  @override
  ConsumerState<EditIncomePage> createState() => _EditIncomePageState();
}

class _EditIncomePageState extends ConsumerState<EditIncomePage> {
  late final TextEditingController nameCtrl;
  late final TextEditingController amountCtrl;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.income.name);
    amountCtrl = TextEditingController(text: widget.income.amount.toStringAsFixed(0));
  }

  Future<void> _save() async {
    if (saving) return;
    final amount = CurrencyInputFormatter.parse(amountCtrl.text);
    if (amount <= 0 || nameCtrl.text.trim().isEmpty) {
      showError(context, 'Datos incompletos', 'Ingresa un nombre y un monto válido');
      return;
    }

    setState(() => saving = true);
    try {
      final error = await ref.read(incomeNotifierProvider.notifier).update(
            id: widget.income.id,
            amount: amount,
            name: nameCtrl.text.trim(),
          );
      if (!mounted) return;
      if (error == null) {
        showSuccess(context, 'Ingreso actualizado');
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
        title: const Text('Editar ingreso'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(controller: nameCtrl, label: 'Nombre del ingreso'),
              const SizedBox(height: 20),
              AppTextField(
                controller: amountCtrl,
                label: 'Monto',
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
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
      ),
    );
  }
}