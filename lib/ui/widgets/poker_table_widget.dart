import 'package:flutter/material.dart';
import '../../domains/models/game_model.dart';

class PokerTableWidget extends StatelessWidget {
  const PokerTableWidget({required this.game, this.child, super.key});

  final GameModel game;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Fondo con gradiente radial
          Container(
            width: 340,
            height: 200,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(120)),
          ),
          // Tres aros concéntricos tipo neón
          CustomPaint(
            size: const Size(340, 200),
            painter: _PokerTableNeonPainter(theme: theme),
          ),
          // Child centrado
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _PokerTableNeonPainter extends CustomPainter {
  _PokerTableNeonPainter({required this.theme});
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    // Especificaciones para cada óvalo según Figma
    final List<_OvalGlowSpec> ovals = <_OvalGlowSpec>[
      _OvalGlowSpec(
        padding: 0,
        stroke: 2,
        borderColor: theme.colorScheme.secondary,
        blurColor: theme.colorScheme.secondary.withValues(alpha: 0.4),
        blurSigma: 12,
        extraGlow: theme.colorScheme.secondary.withValues(alpha: 0.4),
        extraGlowSigma: 16,
      ),
      _OvalGlowSpec(
        padding: 24,
        stroke: 2,
        borderColor: theme.primaryColorLight,
        blurColor: theme.primaryColorLight.withValues(alpha: 0.25),
        blurSigma: 10,
        extraGlow: theme.primaryColorLight.withValues(alpha: 0.25),
        extraGlowSigma: 1,
      ),
      _OvalGlowSpec(
        padding: 40,
        stroke: 1,
        borderColor: theme.colorScheme.secondary,
        blurColor: theme.canvasColor.withValues(alpha: 0.15),
        blurSigma: 8,
        extraGlow: Colors.transparent,
        extraGlowSigma: 0,
      ),
    ];
    const double baseRadius = 120;
    for (final _OvalGlowSpec oval in ovals) {
      final double pad = oval.padding;
      final Rect rect = Rect.fromLTWH(
        pad,
        pad,
        size.width - 2 * pad,
        size.height - 2 * pad,
      );
      final RRect rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(baseRadius - pad),
      );
      // Glow principal
      if (oval.blurSigma > 0) {
        final Paint blurPaint = Paint()
          ..color = oval.blurColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = oval.stroke + 2
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, oval.blurSigma);
        canvas.drawRRect(rrect, blurPaint);
      }
      // Glow extra (azulado, solo exterior)
      if (oval.extraGlowSigma > 0) {
        final Paint extraGlowPaint = Paint()
          ..color = oval.extraGlow
          ..style = PaintingStyle.stroke
          ..strokeWidth = oval.stroke + 4
          ..maskFilter = MaskFilter.blur(BlurStyle.inner, oval.extraGlowSigma);
        canvas.drawRRect(rrect, extraGlowPaint);
      }
      // Borde nítido
      final Paint borderPaint = Paint()
        ..color = oval.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = oval.stroke;
      canvas.drawRRect(rrect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OvalGlowSpec {
  const _OvalGlowSpec({
    required this.padding,
    required this.stroke,
    required this.borderColor,
    required this.blurColor,
    required this.blurSigma,
    required this.extraGlow,
    required this.extraGlowSigma,
  });
  final double padding;
  final double stroke;
  final Color borderColor;
  final Color blurColor;
  final double blurSigma;
  final Color extraGlow;
  final double extraGlowSigma;
}
