import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../domain/models/game_model.dart';
import '../../domain/repositories/game_repository.dart';

import '../gateways/game_gateway_impl.dart';

class GameRepositoryImpl implements GameRepository {
  const GameRepositoryImpl(this.gateway);
  final GameGatewayImpl gateway;

  @override
  Future<Either<ErrorItem, void>> saveGame(GameModel game) async {
    try {
      await gateway.saveGame(game.toJson());
      return Right<ErrorItem, void>(null);
    } catch (e) {
      return Left<ErrorItem, GameModel>(
        ErrorItem(
          title: 'Save Game Error',
          code: 'SAVE_GAME_ERROR',
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<ErrorItem, GameModel>> readGame(String gameId) async {
    try {
      final Map<String, dynamic>? json = await gateway.readGame(gameId);
      if (json == null) {
        return Left<ErrorItem, GameModel>(
          ErrorItem(
            title: 'Game Not Found',
            code: 'GAME_NOT_FOUND',
            description: 'No game found with id $gameId',
          ),
        );
      }
      return Right<ErrorItem, GameModel>(GameModel.fromJson(json));
    } catch (e) {
      return Left<ErrorItem, GameModel>(
        ErrorItem(
          title: 'Read Game Error',
          code: 'READ_GAME_ERROR',
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Stream<Either<ErrorItem, GameModel?>> gameStream(String gameId) {
    return gateway.gameStream(gameId).map((Map<String, dynamic>? json) {
      if (json == null) {
        return Left<ErrorItem, GameModel?>(
          ErrorItem(
            title: 'Game Not Found',
            code: 'GAME_NOT_FOUND',
            description: 'No game found with id $gameId',
          ),
        );
      }
      return Right<ErrorItem, GameModel?>(GameModel.fromJson(json));
    });
  }

  @override
  Stream<Either<ErrorItem, List<GameModel>>> gamesStream() {
    return gateway.gamesStream().map((List<Map<String, dynamic>> list) {
      try {
        return Right<ErrorItem, List<GameModel>>(
          list
              .map((Map<String, dynamic> json) => GameModel.fromJson(json))
              .toList(),
        );
      } catch (e) {
        return Left<ErrorItem, List<GameModel>>(
          ErrorItem(
            title: 'Games Stream Error',
            code: 'GAMES_STREAM_ERROR',
            description: e.toString(),
          ),
        );
      }
    });
  }
}
