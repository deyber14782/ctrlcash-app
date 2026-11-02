import 'package:ctrlcashapp/core/notifications/notification_service.dart';
import 'package:ctrlcashapp/features/auth/presentation/pages/change_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/security/biometric_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController nameCtrl;
  late TextEditingController amountCtrl;
  String frequency = 'mensual';
  bool saving = false;

  final _biometric = sl<BiometricService>();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _biometricLoginEnabled = false;

  final _notif = sl<NotificationService>();
  bool _reminderEnabled = false;
  int _reminderHour = 20;
  int _reminderMinute = 0;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    nameCtrl = TextEditingController(text: user?.displayName ?? '');
    final amount = user?.paymentAmount ?? 0;
    amountCtrl = TextEditingController(
      text: amount > 0 ? amount.toStringAsFixed(0) : '',
    );
    frequency = user?.paymentFrequency ?? 'mensual';
    _loadBiometric();
    _loadReminder();
  }

  Future<void> _loadBiometric() async {
    final available = await _biometric.isAvailable();
    final enabled = await _biometric.isEnabled();
    final loginEnabled = await _biometric.isLoginEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
        _biometricLoginEnabled = loginEnabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final ok = await _biometric.authenticate();
      if (!ok) {
        if (mounted) showError(context, 'No se pudo verificar tu huella');
        return;
      }
    }
    await _biometric.setEnabled(value);
    if (!mounted) return;
    setState(() => _biometricEnabled = value);
    showSuccess(
      context,
      value ? 'Bloqueo con huella activado' : 'Bloqueo con huella desactivado',
    );
  }

  Future<void> _toggleBiometricLogin(bool value) async {
    if (value) {
      final password = await _askPassword();
      if (password == null || password.isEmpty) return;

      final ok = await _biometric.authenticate();
      if (!ok) {
        if (mounted) showError(context, 'No se pudo verificar tu huella');
        return;
      }

      final user = ref.read(authNotifierProvider).user;
      final email = user?.email ?? '';
      if (email.isEmpty) {
        if (mounted) showError(context, 'No se pudo obtener tu correo');
        return;
      }

      await _biometric.enableLogin(email: email, password: password);
      if (mounted) {
        setState(() => _biometricLoginEnabled = true);
        showSuccess(context, 'Inicio de sesión con huella activado');
      }
    } else {
      await _biometric.disableLogin();
      if (mounted) {
        setState(() => _biometricLoginEnabled = false);
        showSuccess(context, 'Inicio de sesión con huella desactivado');
      }
    }
  }

  Future<String?> _askPassword() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirma tu contraseña',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'La necesitamos para activar el ingreso con huella',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: ctrl,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppColors.accentLight),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, ctrl.text),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(color: AppColors.accentLight),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (saving) return;
    if (nameCtrl.text.trim().isEmpty) {
      showError(context, 'El nombre no puede estar vacío');
      return;
    }
    final amount = CurrencyInputFormatter.parse(amountCtrl.text);

    setState(() => saving = true);
    try {
      final ok = await ref
          .read(authNotifierProvider.notifier)
          .updateProfile(
            displayName: nameCtrl.text.trim(),
            paymentFrequency: frequency,
            paymentAmount: amount,
          );
      if (!mounted) return;
      if (ok) {
        showSuccess(context, 'Datos actualizados');
        Navigator.of(context).pop();
      } else {
        showError(context, 'No se pudo actualizar', 'Inténtalo de nuevo');
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _loadReminder() async {
    final enabled = await _notif.isReminderEnabled();
    final time = await _notif.getReminderTime();
    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
        _reminderHour = time.hour;
        _reminderMinute = time.minute;
      });
    }
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      final granted = await _notif.requestPermission();
      if (!granted) {
        if (mounted) showError(context, 'Activa los permisos de notificación');
        return;
      }
      await _notif.enableReminder(hour: _reminderHour, minute: _reminderMinute);
      if (mounted) {
        setState(() => _reminderEnabled = true);
        showSuccess(
          context,
          'Recordatorio activado',
          'Te avisaremos a las ${_formatTime(_reminderHour, _reminderMinute)}',
        );
      }
    } else {
      await _notif.disableReminder();
      if (mounted) {
        setState(() => _reminderEnabled = false);
        showSuccess(context, 'Recordatorio desactivado');
      }
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
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
    if (picked != null) {
      setState(() {
        _reminderHour = picked.hour;
        _reminderMinute = picked.minute;
      });
      if (_reminderEnabled) {
        await _notif.enableReminder(
          hour: _reminderHour,
          minute: _reminderMinute,
        );
        if (mounted) {
          showSuccess(
            context,
            'Hora actualizada',
            'Te avisaremos a las ${_formatTime(_reminderHour, _reminderMinute)}',
          );
        }
      }
    }
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Editar perfil',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            AppTextField(controller: nameCtrl, label: 'Nombre'),
            const SizedBox(height: 20),
            Text(
              'Frecuencia de pago',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _freqChip('semanal', 'Semanal'),
                _freqChip('quincenal', 'Quincenal'),
                _freqChip('mensual', 'Mensual'),
              ],
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: amountCtrl,
              label: 'Monto de pago',
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
            ),

            if (_biometricAvailable) ...[
              const SizedBox(height: 28),
              Text(
                'Seguridad',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 12),
              _toggleCard(
                icon: Icons.login_rounded,
                title: 'Iniciar sesión con huella',
                subtitle: 'Entra sin escribir tu contraseña',
                value: _biometricLoginEnabled,
                onChanged: _toggleBiometricLogin,
              ),
              const SizedBox(height: 28),
              Text(
                'Notificaciones',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 12),
              _toggleCard(
                icon: Icons.notifications_rounded,
                title: 'Recordarme registrar gastos',
                subtitle: 'Un aviso diario para no olvidar',
                value: _reminderEnabled,
                onChanged: _toggleReminder,
              ),
              if (_reminderEnabled) ...[
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  onTap: _pickReminderTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Hora del recordatorio',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          _formatTime(_reminderHour, _reminderMinute),
                          style: const TextStyle(color: AppColors.accentLight, fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _toggleCard(
                icon: Icons.fingerprint_rounded,
                title: 'Bloqueo con huella',
                subtitle: 'Pide tu huella al abrir la app',
                value: _biometricEnabled,
                onChanged: _toggleBiometric,
              ),
            ],
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: saving ? null : _save,
              child: Text(
                saving ? 'GUARDANDO...' : 'GUARDAR CAMBIOS',
                style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              ),
              child: const Text(
                'CAMBIAR CONTRASEÑA',
                style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accentLight, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _freqChip(String value, String label) {
    final selected = frequency == value;
    return GestureDetector(
      onTap: () => setState(() => frequency = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}