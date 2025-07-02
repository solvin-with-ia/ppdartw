import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../domain/models/game_model.dart';
import '../domain/usecases/game/get_games_stream_usecase.dart';
import 'bloc_game.dart';

/// BlocGames: Administra la lista de juegos activos y la selección de un juego.
class BlocGames {
  BlocGames({required this.getGamesStreamUsecase, required this.blocGame}) {
    _subscribeToGames();
  }

  final GetGamesStreamUsecase getGamesStreamUsecase;
  final BlocGame blocGame;

  // Stream de todos los juegos activos
  final ValueNotifier<List<GameModel>> games = ValueNotifier<List<GameModel>>(
    <GameModel>[],
  );

  // Juego seleccionado (puede ser null)
  final ValueNotifier<GameModel?> selectedGame = ValueNotifier<GameModel?>(
    null,
  );

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
          games.value = gamesList;
          // Si el juego seleccionado ya no existe, lo deselecciona
          if (selectedGame.value != null &&
              !gamesList.any((GameModel g) => g.id == selectedGame.value!.id)) {
            selectedGame.value = null;
          }
        },
      );
    });
  }

  /// Selecciona un juego por ID y actualiza BlocGame
  void selectGame(String gameId) {
    final GameModel game = games.value.firstWhere(
      (GameModel g) => g.id == gameId,
      orElse: () => GameModel.empty(),
    );
    if (game.id.isEmpty) {
      return;
    }
    selectedGame.value = game;
    blocGame.subscribeToGame(gameId);
  }

  /// Limpieza de recursos
  void dispose() {
    _gamesSubscription?.cancel();
    games.dispose();
    selectedGame.dispose();
  }
}
