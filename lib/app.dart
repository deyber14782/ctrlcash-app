import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/security/biometric_gate.dart';

class CtrlCashApp extends StatelessWidget {
  const CtrlCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CtrlCash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
      builder: (context, child) {
        return BiometricGate(child: child ?? const SizedBox.shrink());
      },
    );
  }
}