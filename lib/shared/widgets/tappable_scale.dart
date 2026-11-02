import 'package:flutter/material.dart';

class TappableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TappableScale({super.key, required this.child, this.onTap});

  @override
  State<TappableScale> createState() => _TappableScaleState();
}

class _TappableScaleState extends State<TappableScale> {
  double _scale = 1.0;

  void _down(_) => setState(() => _scale = 0.97);
  void _up(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}