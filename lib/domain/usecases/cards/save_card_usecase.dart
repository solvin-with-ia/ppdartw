import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../models/card_model.dart';
import '../../repositories/cards_repository.dart';

class SaveCardUsecase {
  const SaveCardUsecase(this.repository);
  final CardsRepository repository;

  Future<Either<ErrorItem, void>> call(CardModel card) {
    return repository.saveCard(card);
  }
}
