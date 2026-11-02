import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_notifier.dart';
import '../../../../shared/utils/currency_input_formatter.dart';

class CompleteProfilePage extends ConsumerStatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  ConsumerState<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  String frequency = 'mensual';
  final amountCtrl = TextEditingController();
  bool saving = false;

  Future<void> _save() async {
    final amount = CurrencyInputFormatter.parse(amountCtrl.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido')),
      );
      return;
    }
    setState(() => saving = true);
    final ok = await ref.read(authNotifierProvider.notifier).completeFinancialProfile(
          paymentFrequency: frequency,
          paymentAmount: amount,
        );
    if (!mounted) return;
    setState(() => saving = false);
    if (ok) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [AppColors.surfaceElevated, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ListView(
              children: [
                const SizedBox(height: 40),
                Text('Completa tu perfil',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Text('Necesitamos unos datos para ayudarte mejor.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 36),
                Text('Frecuencia de pago',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _freqChip('semanal', 'Semanal'),
                    const SizedBox(width: 10),
                    _freqChip('quincenal', 'Quincenal'),
                    const SizedBox(width: 10),
                    _freqChip('mensual', 'Mensual'),
                  ],
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: amountCtrl,
                  label: '¿Cuánto te pagan?',
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: Text(saving ? 'GUARDANDO...' : 'CONTINUAR',
                      style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _freqChip(String value, String label) {
    final selected = frequency == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => frequency = value),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.surface,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: selected ? AppColors.accent : AppColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 13)),
        ),
      ),
    );
  }
}