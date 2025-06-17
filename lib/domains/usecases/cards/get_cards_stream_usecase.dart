import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../models/card_model.dart';
import 'cards_repository.dart';

class GetCardsStreamUsecase {
  const GetCardsStreamUsecase(this.repository);
  final CardsRepository repository;

  Stream<Either<ErrorItem, List<CardModel>>> call() {
    return repository.cardsStream();
  }
}
