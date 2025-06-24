import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../blocs/bloc_game.dart';
import '../../domain/models/card_model.dart';
import '../../domain/models/game_model.dart';
import '../../domain/models/vote_model.dart';
import 'card_model_widget.dart';
// Si inline_text_widget.dart no existe, usa Text en su lugar.

class DeckWidget extends StatelessWidget {
  const DeckWidget({
    required this.blocGame,
    super.key,
    this.title = 'Elige una carta ',
    this.height = 126,
    this.cardHeight = 90,
    this.spacing = 12,
  });

  final BlocGame blocGame;
  final String title;
  final double height;
  final double cardHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    return StreamBuilder<GameModel>(
      stream: blocGame.gameStream,
      builder: (BuildContext context, AsyncSnapshot<GameModel> snapshot) {
        final GameModel game = snapshot.data ?? blocGame.selectedGame;
        final UserModel? user = blocGame.blocSession.user;
        // Busca el voto actual del usuario
        final String selectedCardId = game.votes
            .firstWhere(
              (VoteModel v) => v.userId == user?.id,
              orElse: () => const VoteModel(userId: ''),
            )
            .cardId;
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
                  child: Text(
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
                      children: game.deck
                          .map(
                            (CardModel card) => Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing / 2,
                              ),
                              child: CardModelWidget(
                                card: card,
                                selected:
                                    card.id == selectedCardId &&
                                    selectedCardId != '',
                                onTap: () => blocGame.setVote(card),
                              ),
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
      },
    );
  }
}
