import 'dart:ui';
import 'package:flutter/material.dart';

class BackdropWidget extends StatelessWidget {
  const BackdropWidget({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Fondo difuso (blur)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
          // Indicador de carga y mensaje
          child,
        ],
      ),
    );
  }
}
