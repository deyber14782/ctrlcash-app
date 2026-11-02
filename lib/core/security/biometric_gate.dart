import 'package:flutter/material.dart';
import '../di/injection.dart';
import 'biometric_service.dart';
import '../../features/auth/presentation/pages/biometric_lock_page.dart';

/// Envuelve la app y muestra el bloqueo por huella al arrancar,
/// solo si el usuario activó la biometría.
class BiometricGate extends StatefulWidget {
  final Widget child;
  const BiometricGate({super.key, required this.child});

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> {
  final _biometric = sl<BiometricService>();
  bool _checking = true;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _checkLock();
  }

  Future<void> _checkLock() async {
    final enabled = await _biometric.isEnabled();
    if (mounted) {
      setState(() {
        _locked = enabled;
        _checking = false;
      });
    }
  }

  void _unlock() {
    if (mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    // Mientras revisa, muestra la app (evita parpadeo); si está bloqueada, tapa con el lock
    if (_checking) return widget.child;

    return Stack(
      children: [
        widget.child,
        if (_locked)
          BiometricLockPage(onUnlocked: _unlock),
      ],
    );
  }
}