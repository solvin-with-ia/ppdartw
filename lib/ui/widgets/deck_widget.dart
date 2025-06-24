import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';
import '../../domain/models/card_model.dart';
import 'card_model_widget.dart';

class DeckWidget extends StatelessWidget {
  const DeckWidget({
    required this.deck,
    super.key,
    this.title = 'Elige una carta',
    this.height = 126,
    this.cardHeight = 90,
    this.spacing = 12,
  });

  final List<CardModel> deck;
  final String title;
  final double height;
  final double cardHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 21,
              width: width,
              child: InlineTextWidget(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: cardHeight,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: deck
                      .map(
                        (CardModel card) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing / 2,
                          ),
                          child: CardModelWidget(card: card),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
