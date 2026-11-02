import 'package:flutter/material.dart';

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    // Curva suave en forma de S usando dos beziers en vez de una sola,
    // para que no se vea como un "mordisco" sino una ola fluida
    path.cubicTo(
      size.width * 0.25, size.height,
      size.width * 0.75, size.height - 90,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}