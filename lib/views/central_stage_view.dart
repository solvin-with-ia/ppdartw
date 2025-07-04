import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../blocs/bloc_game.dart';
import '../blocs/bloc_session.dart';
import '../domain/models/game_model.dart';
import '../ui/widgets/button_widget.dart';
import '../ui/widgets/deck_widget.dart';
import '../ui/widgets/logo_horizontal_widget.dart';
import '../ui/widgets/planning_poker_table_widget.dart';
import '../ui/widgets/user_square_widget.dart';
import '../ui/widgets/votes_deck_widget.dart';

class CentralStageView extends StatelessWidget {
  const CentralStageView({
    required this.blocGame,
    required this.blocSession,
    super.key,
  });

  final BlocGame blocGame;
  final BlocSession blocSession;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return StreamBuilder<UserModel?>(
      stream: blocSession.userStream,
      builder: (BuildContext context, AsyncSnapshot<UserModel?> userSnapshot) {
        final UserModel? user = userSnapshot.data;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<GameModel>(
          stream: blocGame.gameStream,
          initialData: blocGame.selectedGame,
          builder:
              (BuildContext context, AsyncSnapshot<GameModel> gameSnapshot) {
                final GameModel game = blocGame.selectedGame;
                return Scaffold(
                  backgroundColor: theme.colorScheme.surface,
                  body: Stack(
                    children: <Widget>[
                      // Layout principal
                      SafeArea(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  UserSquareWidget(
                                    user: user,
                                    onTap: blocGame.showNameAndRoleModal,
                                  ),
                                  const Spacer(),
                                  const LogoHorizontalWidget(
                                    label: 'Planning Poker',
                                  ),
                                  const SizedBox(width: 12),
                                  ButtonWidget(
                                    label: 'Invitar jugadores',
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Mesa completa Planning Poker
                            Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                PlanningPokerTableWidget(blocGame: blocGame),
                                if (game.votes.isNotEmpty)
                                  ButtonWidget(
                                    label: game.votesRevealed
                                        ? 'Nueva votación'
                                        : 'Revelar votos',
                                    onTap: game.votesRevealed
                                        ? blocGame.resetRound
                                        : blocGame.revealVotes,
                                  ),
                              ],
                            ),
                            const Spacer(),
                            // Cartas disponibles
                            if (game.deck.isNotEmpty)
                              if (game.deck.isNotEmpty && !game.votesRevealed)
                                DeckWidget(blocGame: blocGame),
                              if (game.votesRevealed)
                                VotesDeckWidget(blocGame: blocGame),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
        );
      },
    );
  }
}
