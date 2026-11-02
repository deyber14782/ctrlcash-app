import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../providers/income_notifier.dart';

class AddIncomePage extends ConsumerStatefulWidget {
  const AddIncomePage({super.key});

  @override
  ConsumerState<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends ConsumerState<AddIncomePage> {
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  bool saving = false;

  Future<void> _save() async {
    if (saving) return;

    final amount = CurrencyInputFormatter.parse(amountCtrl.text);
    if (amount <= 0 || nameCtrl.text.trim().isEmpty) {
      showError(context, 'Datos incompletos', 'Ingresa un nombre y un monto válido');
      return;
    }

    setState(() => saving = true);
    try {
      final ok = await ref
          .read(incomeNotifierProvider.notifier)
          .add(amount: amount, name: nameCtrl.text.trim());

      if (!mounted) return;
      if (ok) {
        showSuccess(context, 'Ingreso guardado');
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
        title: const Text('Nuevo ingreso'),
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
                child: Text(
                  saving ? 'GUARDANDO...' : 'GUARDAR INGRESO',
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