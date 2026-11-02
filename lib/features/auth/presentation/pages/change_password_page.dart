import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../providers/auth_notifier.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool saving = false;

  Future<void> _save() async {
    if (saving) return;

    if (currentCtrl.text.isEmpty) {
      showError(context, 'Ingresa tu contraseña actual');
      return;
    }
    if (newCtrl.text.length < 6) {
      showError(context, 'Contraseña muy corta', 'Debe tener al menos 6 caracteres');
      return;
    }
    if (newCtrl.text != confirmCtrl.text) {
      showError(context, 'Las contraseñas no coinciden');
      return;
    }

    setState(() => saving = true);
    try {
      final error = await ref.read(authNotifierProvider.notifier).changePassword(
            currentPassword: currentCtrl.text,
            newPassword: newCtrl.text,
          );
      if (!mounted) return;
      if (error == null) {
        showSuccess(context, 'Contraseña actualizada');
        Navigator.of(context).pop();
      } else {
        showError(context, error);
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
        title: const Text('Cambiar contraseña'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Por seguridad, ingresa tu contraseña actual antes de crear una nueva.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 28),
            AppTextField(
                controller: currentCtrl, label: 'Contraseña actual', obscure: true),
            const SizedBox(height: 20),
            AppTextField(
                controller: newCtrl, label: 'Nueva contraseña', obscure: true),
            const SizedBox(height: 20),
            AppTextField(
                controller: confirmCtrl, label: 'Confirmar nueva contraseña', obscure: true),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: saving ? null : _save,
              child: Text(saving ? 'GUARDANDO...' : 'CAMBIAR CONTRASEÑA',
                  style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}