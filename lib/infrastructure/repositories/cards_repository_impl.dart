import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../domain/models/card_model.dart';
import '../../domain/repositories/cards_repository.dart';

import '../gateways/cards_gateway_impl.dart';

class CardsRepositoryImpl implements CardsRepository {
  const CardsRepositoryImpl(this.gateway);
  final CardsGatewayImpl gateway;

  @override
  Future<Either<ErrorItem, void>> saveCard(CardModel card) async {
    try {
      await gateway.saveCard(card.toJson());
      return Right<ErrorItem, CardModel>(card);
    } catch (e) {
      return Left<ErrorItem, CardModel>(
        ErrorItem(
          title: 'Save Card Error',
          code: 'SAVE_CARD_ERROR',
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<ErrorItem, CardModel>> readCard(String cardId) async {
    try {
      final Map<String, dynamic>? json = await gateway.readCard(cardId);
      if (json == null) {
        return Left<ErrorItem, CardModel>(
          ErrorItem(
            title: 'Card Not Found',
            code: 'CARD_NOT_FOUND',
            description: 'No card found with id $cardId',
          ),
        );
      }
      return Right<ErrorItem, CardModel>(CardModel.fromJson(json));
    } catch (e) {
      return Left<ErrorItem, CardModel>(
        ErrorItem(
          title: 'Read Card Error',
          code: 'READ_CARD_ERROR',
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Stream<Either<ErrorItem, CardModel?>> cardStream(String cardId) {
    return gateway.cardStream(cardId).map((Map<String, dynamic>? json) {
      if (json == null) {
        return Left<ErrorItem, CardModel?>(
          ErrorItem(
            title: 'Card Not Found',
            code: 'CARD_NOT_FOUND',
            description: 'No card found with id $cardId',
          ),
        );
      }
      return Right<ErrorItem, CardModel?>(CardModel.fromJson(json));
    });
  }

  @override
  Stream<Either<ErrorItem, List<CardModel>>> cardsStream() {
    return gateway.cardsStream().map((List<Map<String, dynamic>> list) {
      try {
        return Right<ErrorItem, List<CardModel>>(
          list
              .map((Map<String, dynamic> json) => CardModel.fromJson(json))
              .toList(),
        );
      } catch (e) {
        return Left<ErrorItem, List<CardModel>>(
          ErrorItem(
            title: 'Cards Stream Error',
            code: 'CARDS_STREAM_ERROR',
            description: e.toString(),
          ),
        );
      }
    });
  }
}
