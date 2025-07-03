import 'dart:async';

import 'package:flutter/foundation.dart';

/// BlocGames: Administra la lista de juegos activos y la selección de un juego.
import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../domain/models/game_model.dart';
import '../domain/usecases/game/get_games_stream_usecase.dart';
import '../ui/modals/games_list_modal.dart';
import 'bloc_game.dart';

class BlocGames {
  BlocGames({required this.getGamesStreamUsecase, required this.blocGame}) {
    _subscribeToGames();
  }

  final GetGamesStreamUsecase getGamesStreamUsecase;
  final BlocGame blocGame;

  final BlocGeneral<List<GameModel>> _gamesBloc = BlocGeneral<List<GameModel>>(
    <GameModel>[],
  );

  /// Devuelve el juego seleccionado actual (GameModel.empty() si ninguno)
  GameModel get selectedGame => blocGame.selectedGame;

  Stream<List<GameModel>> get gamesStream => _gamesBloc.stream;
  List<GameModel> get games => _gamesBloc.value;

  StreamSubscription<Either<ErrorItem, List<GameModel>>>? _gamesSubscription;

  /// Suscribirse al stream global de juegos
  void _subscribeToGames() {
    _gamesSubscription?.cancel();
    _gamesSubscription = getGamesStreamUsecase().listen((
      Either<ErrorItem, List<GameModel>> either,
    ) {
      either.fold(
        (ErrorItem error) {
          // Luego: Manejar el error (mostrar en UI, log, etc)
          debugPrint(
            '[BlocGames] Error en stream de juegos: \\${error.title} - \\${error.description}',
          );
        },
        (List<GameModel> gamesList) {
          _gamesBloc.value = gamesList;
          // Si el juego seleccionado ya no existe, lo deselecciona
          if (selectedGame.id.isNotEmpty &&
              !gamesList.any((GameModel g) => g.id == selectedGame.id)) {
            blocGame.subscribeToGame('none');
          }
        },
      );
    });
  }

  /// Selecciona un juego por ID y actualiza BlocGame
  void selectGame(String gameId) {
    final GameModel game = games.firstWhere(
      (GameModel g) => g.id == gameId,
      orElse: () => GameModel.empty(),
    );
    if (game.id.isEmpty) {
      return;
    }
    blocGame.subscribeToGame(gameId);
  }

  /// Muestra el modal de selección de partida
  void showGamesModal() {
    blocGame.blocModal.showModal(
      GamesListModal(
        games: games,
        onSelect: (GameModel game) {
          selectGame(game.id);
          blocGame.blocModal.hideModal();
        },
        onCancel: () => blocGame.blocModal.hideModal(),
      ),
    );
  }

  /// Limpieza de recursos
  void dispose() {
    _gamesSubscription?.cancel();
    _gamesBloc.dispose();
  }
}
