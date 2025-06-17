import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../models/card_model.dart';
import '../../repositories/cards_repository.dart';

class GetCardStreamUsecase {
  const GetCardStreamUsecase(this.repository);
  final CardsRepository repository;

  Stream<Either<ErrorItem, CardModel?>> call(String cardId) {
    return repository.cardStream(cardId);
  }
}
