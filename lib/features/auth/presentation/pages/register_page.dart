import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/curve_clipper.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../../../../core/errors/error_messages.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final ageCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final panelHeight = 300 + topInset;

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        showSuccess(context, 'Cuenta creada', 'Ahora inicia sesión');
        context.go('/login');
      }
      if (next.status == AuthStatus.error) {
        showError(context, humanizeError(next.errorMessage ?? ''));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipPath(
                  clipper: CurveClipper(),
                  child: Container(
                    height: panelHeight,
                    padding: EdgeInsets.fromLTRB(28, topInset + 76, 28, 60),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.accent, AppColors.surfaceElevated],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Crea tu cuenta',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 30, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Empieza a controlar tus finanzas hoy',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(controller: nameCtrl, label: 'Nombre'),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: emailCtrl,
                            label: 'Correo electrónico',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: ageCtrl,
                            label: 'Edad',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(controller: passCtrl, label: 'Contraseña', obscure: true),
                          const SizedBox(height: 16),
                          AppTextField(
                              controller: confirmPassCtrl, label: 'Confirmar contraseña', obscure: true),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: state.status == AuthStatus.loading
                                  ? null
                                  : () {
                                      final age = int.tryParse(ageCtrl.text.trim());
                                      if (nameCtrl.text.trim().isEmpty) {
                                        showError(context, 'Ingresa tu nombre');
                                        return;
                                      }
                                      if (age == null) {
                                        showError(context, 'Ingresa una edad válida');
                                        return;
                                      }
                                      if (age < 18) {
                                        showError(context, 'Debes ser mayor de edad',
                                            'Necesitas tener 18 años o más');
                                        return;
                                      }
                                      if (passCtrl.text.trim() != confirmPassCtrl.text.trim()) {
                                        showError(context, 'Las contraseñas no coinciden');
                                        return;
                                      }
                                      if (passCtrl.text.trim().length < 6) {
                                        showError(context, 'Contraseña muy corta',
                                            'Debe tener al menos 6 caracteres');
                                        return;
                                      }
                                      notifier.register(
                                        email: emailCtrl.text.trim(),
                                        password: passCtrl.text.trim(),
                                        displayName: nameCtrl.text.trim(),
                                        age: age,
                                      );
                                    },
                              child: Text(
                                state.status == AuthStatus.loading ? 'Creando...' : 'Registrarme',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text.rich(
                        TextSpan(
                          text: '¿Ya tienes cuenta? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: const [
                            TextSpan(
                              text: 'Inicia sesión',
                              style: TextStyle(color: AppColors.accentLight, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: bottomInset + 10),
              ],
            ),
          ),
          Positioned(
            top: topInset + 12,
            left: 12,
            child: _backButton(() => context.go('/login')),
          ),
        ],
      ),
    );
  }

  Widget _backButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}