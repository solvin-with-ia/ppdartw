import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../blocs/bloc_game.dart';
import '../../domain/models/card_model.dart';
import '../../domain/models/game_model.dart';
import '../../domain/models/vote_model.dart';
import 'play_card_model_widget.dart';
import 'poker_table_widget.dart';

/// Widget que representa la mesa completa de Planning Poker con slots para jugadores/espectadores.
class PlanningPokerTableWidget extends StatelessWidget {
  const PlanningPokerTableWidget({required this.blocGame, super.key});

  final BlocGame blocGame;

  static const int _slotsTop = 5;
  static const int _slotsBottom = 5;
  static const int _slotsLeft = 1;
  // _totalSlots ya no se usa, se puede eliminar si no es necesario.

  @override
  Widget build(BuildContext context) {
    final GameModel game = blocGame.selectedGame;
    final List<UserModel?> seats = blocGame.seatsOfPlanningPoker;
    final List<VoteModel> votes = game.votes;

    bool hasVoted(UserModel user) {
      return votes.any(
        (VoteModel v) => v.userId == user.id && v.cardId.isNotEmpty,
      );
    }

    bool isSpectator(UserModel user, GameModel game) {
      return game.spectators.any((UserModel u) => u.id == user.id);
    }

    return SizedBox(
      width: 520,
      height: 390,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Mesa central
          PokerTableWidget(game: game),
          // Slots arriba
          Positioned(
            top: 0,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List<Widget>.generate(_slotsTop, (int i) {
                final UserModel? user = seats[i];
                return user == null
                    ? const SizedBox(width: 36, height: 84)
                    : PlayCardModelWidget(
                        user: user,
                        isSpectator: isSpectator(user, game),
                        selected: hasVoted(user),
                        revealedValue:
                            (game.votesRevealed &&
                                !isSpectator(user, game) &&
                                hasVoted(user))
                            ? (game.deck
                                  .firstWhere(
                                    (CardModel c) =>
                                        c.id ==
                                        votes
                                            .firstWhere(
                                              (VoteModel v) =>
                                                  v.userId == user.id,
                                            )
                                            .cardId,
                                    orElse: () => const CardModel(
                                      id: '',
                                      value: 0,
                                      display: '',
                                      description: '',
                                    ),
                                  )
                                  .display)
                            : null,
                      );
              }),
            ),
          ),
          // Slots abajo
          Positioned(
            bottom: 0,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List<Widget>.generate(_slotsBottom, (int i) {
                final UserModel? user = seats[_slotsTop + _slotsLeft + i];
                return user == null
                    ? const SizedBox(width: 36, height: 84)
                    : PlayCardModelWidget(
                        user: user,
                        isSpectator: isSpectator(user, game),
                        selected: hasVoted(user),
                        revealedValue:
                            (game.votesRevealed &&
                                !isSpectator(user, game) &&
                                hasVoted(user))
                            ? (game.deck
                                  .firstWhere(
                                    (CardModel c) =>
                                        c.id ==
                                        votes
                                            .firstWhere(
                                              (VoteModel v) =>
                                                  v.userId == user.id,
                                            )
                                            .cardId,
                                    orElse: () => const CardModel(
                                      id: '',
                                      value: 0,
                                      display: '',
                                      description: '',
                                    ),
                                  )
                                  .display)
                            : null,
                      );
              }),
            ),
          ),
          // Slot izquierda
          Positioned(
            left: 0,
            top: 80,
            bottom: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Builder(
                  builder: (_) {
                    final UserModel? user = seats[_slotsTop];
                    return user == null
                        ? const SizedBox(width: 36, height: 84)
                        : PlayCardModelWidget(
                            user: user,
                            isSpectator: false,
                            selected: hasVoted(user),
                          );
                  },
                ),
              ],
            ),
          ),
          // Slot derecha
          Positioned(
            right: 0,
            top: 80,
            bottom: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Builder(
                  builder: (_) {
                    final UserModel? user = seats[_slotsTop + 1];
                    return user == null
                        ? const SizedBox(width: 36, height: 84)
                        : PlayCardModelWidget(
                            user: user,
                            isSpectator: false,
                            selected: hasVoted(user),
                          );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
