import 'package:flutter/material.dart';

enum LogoVariant {
  full, // logo + texto, para fondos oscuros o morados (el de la app)
  fullLight, // logo + texto con colores originales, para fondos claros
  icon, // solo el cuadro con la C y la flecha
}

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final LogoVariant variant;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.variant = LogoVariant.full,
  });

  String get _asset {
    switch (variant) {
      case LogoVariant.full:
        return 'assets/images/logo_full_dark.png';
      case LogoVariant.fullLight:
        return 'assets/images/logo_full.png';
      case LogoVariant.icon:
        return 'assets/images/logo_icon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
