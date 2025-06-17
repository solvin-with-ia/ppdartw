import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../models/game_model.dart';

abstract class GameRepository {
  Future<Either<ErrorItem, void>> saveGame(GameModel game);
  Future<Either<ErrorItem, GameModel>> readGame(String gameId);
  Stream<Either<ErrorItem, GameModel?>> gameStream(String gameId);
  Stream<Either<ErrorItem, List<GameModel>>> gamesStream();
}
