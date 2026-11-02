import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/curve_clipper.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../providers/auth_notifier.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final emailCtrl = TextEditingController();
  bool sending = false;
  bool sent = false;

  Future<void> _send() async {
    if (sending) return;
    final email = emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      showError(context, 'Ingresa un correo válido');
      return;
    }
    setState(() => sending = true);
    try {
      final ok = await ref.read(authNotifierProvider.notifier).sendPasswordReset(email);
      if (!mounted) return;
      if (ok) {
        setState(() => sent = true);
      } else {
        showError(context, 'No se pudo enviar el correo', 'Verifica que el email sea correcto');
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: sent
          ? SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: _successView(),
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: _backButton(AppColors.textPrimary, () => Navigator.of(context).pop()),
                  ),
                ],
              ),
            )
          : _formView(topInset, bottomInset),
    );
  }

  Widget _formView(double topInset, double bottomInset) {
    final panelHeight = 280 + topInset;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipPath(
                clipper: CurveClipper(),
                child: Container(
                  height: panelHeight,
                  padding: EdgeInsets.fromLTRB(28, topInset + 76, 28, 54),
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
                      Text('Recuperar\ncontraseña',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 28, color: Colors.white, height: 1.25)),
                      const SizedBox(height: 8),
                      Text('Te ayudamos a volver a tu cuenta',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -36),
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
                        Text(
                          'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          controller: emailCtrl,
                          label: 'Correo electrónico',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: sending ? null : _send,
                            child: Text(sending ? 'Enviando...' : 'Enviar enlace',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: bottomInset + 20),
            ],
          ),
        ),
        Positioned(
          top: topInset + 12,
          left: 12,
          child: _backButton(Colors.white, () => Navigator.of(context).pop()),
        ),
      ],
    );
  }

  Widget _successView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success),
          child: const Icon(Icons.mark_email_read_rounded, color: AppColors.background, size: 32),
        ),
        const SizedBox(height: 24),
        Text('Correo enviado',
            style: Theme.of(context).textTheme.displayMedium, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Revisa tu bandeja de entrada y sigue el enlace para crear una nueva contraseña.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.accentLight),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver al inicio'),
        ),
      ],
    );
  }

  Widget _backButton(Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor == Colors.white
              ? Colors.white.withValues(alpha: 0.2)
              : AppColors.surface,
          shape: BoxShape.circle,
          border: iconColor == Colors.white ? null : Border.all(color: AppColors.border),
        ),
        child: Icon(Icons.arrow_back_rounded, color: iconColor, size: 20),
      ),
    );
  }
}