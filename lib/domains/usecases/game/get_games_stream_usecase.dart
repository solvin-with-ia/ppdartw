import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../models/game_model.dart';
import '../../repositories/game_repository.dart';

class GetGamesStreamUsecase {
  const GetGamesStreamUsecase(this.repository);
  final GameRepository repository;

  Stream<Either<ErrorItem, List<GameModel>>> call() {
    return repository.gamesStream();
  }
}
