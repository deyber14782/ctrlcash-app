import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/security/biometric_service.dart';

class BiometricLockPage extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;
  const BiometricLockPage({super.key, required this.onUnlocked});

  @override
  ConsumerState<BiometricLockPage> createState() => _BiometricLockPageState();
}

class _BiometricLockPageState extends ConsumerState<BiometricLockPage> {
  final _biometric = sl<BiometricService>();
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock());
  }

  Future<void> _tryUnlock() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    final ok = await _biometric.authenticate();
    if (!mounted) return;
    setState(() => _authenticating = false);
    if (ok) {
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.accent, size: 48),
              const SizedBox(height: 24),
              Text('CtrlCash está bloqueado',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Usa tu huella para acceder',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: _authenticating ? null : _tryUnlock,
                icon: const Icon(Icons.fingerprint, color: AppColors.accent),
                label: Text(_authenticating ? 'Verificando...' : 'Desbloquear',
                    style: const TextStyle(color: AppColors.accent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: const RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}