import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:text_responsive/text_responsive.dart';
import 'user_square_widget.dart';

/// Widget que representa la carta/avatar de un usuario en la mesa de juego.
/// - Si el usuario es espectador: muestra UserSquareWidget arriba y el nombre abajo.
/// - Si el usuario es jugador: muestra el reverso de la carta (sin valor) y el nombre abajo.
/// Medidas: 36x84
class PlayCardModelWidget extends StatelessWidget {
  // NUEVO

  const PlayCardModelWidget({
    required this.user,
    required this.isSpectator,
    this.selected = false,
    this.revealedValue,
    super.key,
    this.cardBackColor = const Color(0xFF6C3EFF),
    this.cardBorderColor = Colors.white,
  });
  final String? revealedValue;

  final UserModel user;
  final bool isSpectator;
  final Color cardBackColor;
  final Color cardBorderColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (revealedValue != null) {
      // Mostrar valor centrado en la carta estilo mesa
      return SizedBox(
        width: 36,
        height: 84,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: 36,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cardBorderColor, width: 2),
              ),
              child: Text(
                revealedValue!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 40,
              height: 22,
              child: InlineTextWidget(
                user.displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: 36,
      height: 84,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (isSpectator)
            Expanded(
              child: Center(
                child: FittedBox(
                  child: UserSquareWidget(user: user, displayName: false),
                ),
              ),
            )
          else
            // Reverso de la carta (sin valor)
            Container(
              width: 36,
              height: 58,
              decoration: BoxDecoration(
                color: !isSpectator && selected
                    ? cardBackColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cardBorderColor, width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            width: 40,
            height: 22,
            child: InlineTextWidget(
              user.displayName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
