import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../models/game_model.dart';
import '../../repositories/game_repository.dart';

class GetGameStreamUsecase {
  const GetGameStreamUsecase(this.repository);
  final GameRepository repository;

  Stream<Either<ErrorItem, GameModel?>> call(String gameId) {
    return repository.gameStream(gameId);
  }
}
