import 'package:ctrlcashapp/features/auth/presentation/pages/forgot_password_page.dart';
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
import '../../../../core/di/injection.dart';
import '../../../../core/security/biometric_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final _biometric = sl<BiometricService>();
  bool _biometricLoginAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricLogin();
  }

  Future<void> _checkBiometricLogin() async {
    final enabled = await _biometric.isLoginEnabled();
    if (mounted) setState(() => _biometricLoginAvailable = enabled);
  }

  Future<void> _loginWithBiometric() async {
    final ok = await _biometric.authenticate();
    if (!ok) return;
    final creds = await _biometric.getSavedCredentials();
    if (creds == null) {
      if (mounted) showError(context, 'No hay credenciales guardadas');
      return;
    }
    ref.read(authNotifierProvider.notifier).login(
          email: creds.email,
          password: creds.password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final panelHeight = 320 + topInset;

    ref.listen(authNotifierProvider, (prev, next) {
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
                    padding: EdgeInsets.fromLTRB(28, topInset + 76, 28, 70),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.accentLight, AppColors.accent],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Bienvenido\nde nuevo',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 32, color: Colors.white, height: 1.25)),
                        const SizedBox(height: 10),
                        Text('Inicia sesión para seguir controlando tus finanzas',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -46),
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
                          AppTextField(
                            controller: emailCtrl,
                            label: 'Correo electrónico',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: passCtrl,
                            label: 'Contraseña',
                            obscure: true,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                              ),
                              child: const Text('¿Olvidaste tu contraseña?',
                                  style: TextStyle(color: AppColors.accentLight, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: state.status == AuthStatus.loading
                                  ? null
                                  : () => notifier.login(
                                      email: emailCtrl.text.trim(),
                                      password: passCtrl.text.trim(),
                                    ),
                              child: Text(
                                state.status == AuthStatus.loading ? 'Cargando...' : 'Entrar',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          if (_biometricLoginAvailable) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _loginWithBiometric,
                                icon: const Icon(Icons.fingerprint, color: AppColors.accentLight, size: 20),
                                label: const Text('Entrar con huella',
                                    style: TextStyle(color: AppColors.accentLight, fontSize: 15)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Center(
                    child: TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text.rich(
                        TextSpan(
                          text: '¿No tienes cuenta? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: const [
                            TextSpan(
                              text: 'Regístrate',
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
            child: _backButton(() => context.go('/welcome')),
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