import 'dart:async';

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../domains/models/card_model.dart';
import '../domains/models/game_model.dart';
import '../domains/models/vote_model.dart';
import '../domains/usecases/game/create_game_usecase.dart';
import 'bloc_session.dart';

/// Bloc para manejar la lógica de creación y estado de la partida actual.
class BlocGame {
  BlocGame({required this.blocSession, required this.createGameUsecase});
  final BlocSession blocSession;
  final CreateGameUsecase createGameUsecase;

  final BlocGeneral<GameModel> _gameBloc = BlocGeneral<GameModel>(
    GameModel.empty(),
  );

  Stream<GameModel> get gameStream => _gameBloc.stream;
  GameModel? get currentGame => _gameBloc.value;

  Future<void> createGame({required String name}) async {
    final UserModel? admin = blocSession.user;
    if (admin == null) {
      // Aquí podrías redirigir al login, por ahora simplemente retorna
      return;
    }
    final GameModel game = GameModel(
      id: _generateUuid(),
      name: name,
      admin: admin,
      spectators: const <UserModel>[],
      players: const <UserModel>[],
      votes: const <VoteModel>[],
      isActive: true,
      createdAt: DateTime.now(),
      deck: const <CardModel>[],
    );
    final Either<ErrorItem, void> result = await createGameUsecase.call(game);
    result.fold(
      (ErrorItem error) {
        // Manejo de error opcional
      },
      (_) {
        _gameBloc.value = game;
      },
    );
  }

  void updateGameName(String newName) {
    _gameBloc.value = _gameBloc.value.copyWith(name: newName);
  }

  void dispose() {
    _gameBloc.dispose();
  }

  String _generateUuid() {
    // Puedes reemplazar esto por un paquete uuid si lo deseas
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
