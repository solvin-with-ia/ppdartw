import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

import '../../blocs/bloc_game.dart';
import '../../domain/models/card_model.dart';
import '../../domain/models/game_model.dart';
import '../../domain/models/vote_model.dart';

class VotesDeckWidget extends StatelessWidget {
  const VotesDeckWidget({
    required this.blocGame,
    this.height = 126,
    this.cardHeight = 111,
    this.spacing = 12,
    super.key,
  });

  final BlocGame blocGame;
  final double height;
  final double cardHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double cardWidth = cardHeight * 0.43243;
    return StreamBuilder<GameModel>(
      stream: blocGame.gameStream,
      builder: (BuildContext context, AsyncSnapshot<GameModel> snapshot) {
        final GameModel game = snapshot.data ?? blocGame.selectedGame;
        // Agrupar votos por carta (solo cartas votadas)
        final Map<String, int> votosPorCarta = <String, int>{};
        for (final VoteModel v in game.votes) {
          if (v.cardId.isNotEmpty) {
            votosPorCarta[v.cardId] = (votosPorCarta[v.cardId] ?? 0) + 1;
          }
        }
        // Obtener cartas votadas y ordenarlas como en el deck
        final List<CardModel> cartasVotadas = game.deck
            .where((CardModel c) => votosPorCarta.containsKey(c.id))
            .toList();
        // Calcular promedio
        final double promedio = blocGame.calculateAverage();
        return SizedBox(
          width: width,
          height: height,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: cartasVotadas.map((CardModel card) {
                      final int votos = votosPorCarta[card.id] ?? 0;
                      return Container(
                        width: cardWidth,
                        height: cardHeight,
                        padding: EdgeInsets.symmetric(horizontal: spacing / 3),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: InlineTextWidget(
                                  card.value.toString(),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: cardWidth,
                              height: 20,
                              child: InlineTextWidget(
                                '$votos Voto${votos > 1 ? 's' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                // Promedio
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          InlineTextWidget(
                            'Promedio:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          InlineTextWidget(
                            promedio.toStringAsFixed(1),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
