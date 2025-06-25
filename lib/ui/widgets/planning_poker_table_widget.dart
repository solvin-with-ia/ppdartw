import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../blocs/bloc_game.dart';
import '../../domain/models/game_model.dart';
import 'play_card_model_widget.dart';
import 'poker_table_widget.dart';

/// Widget que representa la mesa completa de Planning Poker con slots para jugadores/espectadores.
class PlanningPokerTableWidget extends StatelessWidget {
  const PlanningPokerTableWidget({required this.blocGame, super.key});

  final BlocGame blocGame;

  static const int _slotsTop = 5;
  static const int _slotsBottom = 5;
  static const int _slotsLeft = 1;
  static const int _slotsRight = 1;
  static const int _totalSlots =
      _slotsTop + _slotsBottom + _slotsLeft + _slotsRight;

  @override
  Widget build(BuildContext context) {
    final GameModel game = blocGame.selectedGame;
    final UserModel? currentUser = blocGame.blocSession.user;
    // --- NUEVA LÓGICA: Usuario actual siempre en el centro abajo ---
    final UserModel protagonistUser =
        currentUser ??
        game.admin; // Usa el usuario actual si se pasa, si no el admin

    // Construir lista de todos los usuarios (jugadores y espectadores)
    final List<UserModel> allUsers = <UserModel>[
      ...game.players,
      ...game.spectators,
    ];
    final List<bool> allIsSpectator = <bool>[
      ...List<bool>.filled(game.players.length, false),
      ...List<bool>.filled(game.spectators.length, true),
    ];

    // Separar usuario actual y el resto
    final int protagonistIdx = allUsers.indexWhere(
      (UserModel u) => u.id == protagonistUser.id,
    );
    UserModel? protagonist;
    bool? protagonistIsSpectator;
    if (protagonistIdx != -1) {
      protagonist = allUsers.removeAt(protagonistIdx);
      protagonistIsSpectator = allIsSpectator.removeAt(protagonistIdx);
    }

    // Mezclar aleatoriamente el resto
    final List<MapEntry<UserModel, bool>> rest =
        List<MapEntry<UserModel, bool>>.generate(
          allUsers.length,
          (int i) => MapEntry<UserModel, bool>(allUsers[i], allIsSpectator[i]),
        )..shuffle();

    // Asignar usuarios a los slots
    final List<UserModel?> slotUsers = List<UserModel?>.filled(
      _totalSlots,
      null,
    );
    final List<bool?> slotSpectator = List<bool?>.filled(_totalSlots, null);

    // Índices de slots
    const int bottomRowStart = _slotsTop + _slotsLeft;
    const int protagonistSlot =
        bottomRowStart + 2; // slot central de los 5 de abajo

    // Colocar protagonista
    if (protagonist != null) {
      slotUsers[protagonistSlot] = protagonist;
      slotSpectator[protagonistSlot] = protagonistIsSpectator;
    }

    // Lista de slots disponibles (excepto el central inferior)
    final List<int> availableSlots = List<int>.generate(
      _totalSlots,
      (int i) => i,
    )..remove(protagonistSlot);

    // Asignar el resto
    for (int i = 0; i < rest.length && i < availableSlots.length; i++) {
      slotUsers[availableSlots[i]] = rest[i].key;
      slotSpectator[availableSlots[i]] = rest[i].value;
    }
    // --- FIN NUEVA LÓGICA ---

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
