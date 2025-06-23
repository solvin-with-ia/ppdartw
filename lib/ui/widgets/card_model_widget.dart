import 'package:flutter/material.dart';

import '../../domains/models/card_model.dart';

class CardModelWidget extends StatelessWidget {
  const CardModelWidget({
    required this.card,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final CardModel card;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 53,
        height: 86,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.secondary.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? theme.colorScheme.secondary : Colors.purpleAccent,
            width: selected ? 3 : 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          card.display,
          style: theme.textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
