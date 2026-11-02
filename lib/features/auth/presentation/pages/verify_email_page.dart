import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  Timer? _timer;
  bool _checking = false;
  bool _resent = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.reload();
    if (user.emailVerified && mounted) {
      _timer?.cancel();
      context.go('/home');
    }
  }

  Future<void> _manualCheck() async {
    setState(() => _checking = true);
    await _check();
    if (mounted) {
      setState(() => _checking = false);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aún no detectamos la verificación')),
        );
      }
    }
  }

  Future<void> _resend() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      if (mounted) setState(() => _resent = true);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mark_email_unread_rounded,
                      color: AppColors.textPrimary, size: 28),
                ),
                const SizedBox(height: 28),
                Text('Verifica tu correo',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 16),
                Text(
                  'Enviamos un enlace de verificación a $email. Ábrelo para activar tu cuenta.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta pantalla se actualizará sola cuando confirmes.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _checking ? null : _manualCheck,
                  child: Text(_checking ? 'VERIFICANDO...' : 'YA VERIFIQUÉ',
                      style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: _resent ? null : _resend,
                  child: Text(_resent ? 'CORREO REENVIADO' : 'REENVIAR CORREO',
                      style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _logout,
                  child: Text('Cerrar sesión',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}