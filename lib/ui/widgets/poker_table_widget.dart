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
      child: Container(
        width: 340,
        height: 200,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 0.9,
            colors: <Color>[
              Colors.deepPurple.shade900.withValues(alpha: 0.98),
              theme.colorScheme.secondary.withValues(alpha: 0.18),
              Colors.transparent,
            ],
            stops: const <double>[0.7, 0.95, 1.0],
          ),
          borderRadius: BorderRadius.circular(120),
          border: Border.all(color: Colors.purpleAccent.shade100, width: 3),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.purpleAccent.withValues(alpha: 0.18),
              blurRadius: 32,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
