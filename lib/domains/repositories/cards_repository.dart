import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../models/card_model.dart';

abstract class CardsRepository {
  Future<Either<ErrorItem, void>> saveCard(CardModel card);
  Future<Either<ErrorItem, CardModel>> readCard(String cardId);
  Stream<Either<ErrorItem, CardModel?>> cardStream(String cardId);
  Stream<Either<ErrorItem, List<CardModel>>> cardsStream();
}
