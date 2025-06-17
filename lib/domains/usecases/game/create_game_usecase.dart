import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../models/game_model.dart';
import 'game_repository.dart';

class CreateGameUsecase {
  const CreateGameUsecase(this.repository);
  final GameRepository repository;

  Future<Either<ErrorItem, void>> call(GameModel game) {
    return repository.saveGame(game);
  }
}
