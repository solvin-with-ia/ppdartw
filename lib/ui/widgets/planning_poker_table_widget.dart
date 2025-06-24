import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../domain/models/game_model.dart';
import 'play_card_model_widget.dart';
import 'poker_table_widget.dart';

/// Widget que representa la mesa completa de Planning Poker con slots para jugadores/espectadores.
class PlanningPokerTableWidget extends StatelessWidget {
  const PlanningPokerTableWidget({required this.game, super.key});

  final GameModel game;

  static const int _slotsTop = 5;
  static const int _slotsBottom = 5;
  static const int _slotsLeft = 1;
  static const int _slotsRight = 1;
  static const int _totalSlots =
      _slotsTop + _slotsBottom + _slotsLeft + _slotsRight;

  @override
  Widget build(BuildContext context) {
    // Mezclar jugadores y espectadores para llenar los 12 slots
    final List<UserModel> users = <UserModel>[
      ...game.players,
      ...game.spectators,
    ];
    final List<bool> isSpectator = <bool>[
      ...List<bool>.filled(game.players.length, false),
      ...List<bool>.filled(game.spectators.length, true),
    ];
    // Asegurar 12 slots, rellenar con null si faltan
    final List<UserModel?> slotUsers = List<UserModel?>.filled(
      _totalSlots,
      null,
    );
    final List<bool?> slotSpectator = List<bool?>.filled(_totalSlots, null);
    for (int i = 0; i < users.length && i < _totalSlots; i++) {
      slotUsers[i] = users[i];
      slotSpectator[i] = isSpectator[i];
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
                final UserModel? user = slotUsers[i];
                final bool? spectator = slotSpectator[i];
                return user == null
                    ? const SizedBox(width: 36, height: 84)
                    : PlayCardModelWidget(
                        user: user,
                        isSpectator: spectator ?? false,
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
                final UserModel? user = slotUsers[_slotsTop + _slotsLeft + i];
                final bool? spectator =
                    slotSpectator[_slotsTop + _slotsLeft + i];
                return user == null
                    ? const SizedBox(width: 36, height: 84)
                    : PlayCardModelWidget(
                        user: user,
                        isSpectator: spectator ?? false,
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
                    final UserModel? user = slotUsers[_slotsTop];
                    final bool? spectator = slotSpectator[_slotsTop];
                    return user == null
                        //? const SizedBox(width: 36, height: 84)
                        ? const SizedBox(width: 36, height: 84)
                        : PlayCardModelWidget(
                            user: user,
                            isSpectator: spectator ?? false,
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
                    final UserModel? user = slotUsers[_slotsTop + 1];
                    final bool? spectator = slotSpectator[_slotsTop + 1];
                    return user == null
                        ? const SizedBox(width: 36, height: 84)
                        : PlayCardModelWidget(
                            user: user,
                            isSpectator: spectator ?? false,
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
