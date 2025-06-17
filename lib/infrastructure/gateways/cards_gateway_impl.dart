import '../../domains/gateways/cards_gateway.dart';
import '../../domains/services/service_ws_database.dart';

class CardsGatewayImpl implements CardsGateway {
  CardsGatewayImpl(this.db);
  final ServiceWsDatabase db;

  @override
  Future<void> saveCard(Map<String, dynamic> cardJson) {
    return db.saveDocument(
      collection: 'cards',
      docId: cardJson['id'] as String,
      data: cardJson,
    );
  }

  @override
  Future<Map<String, dynamic>?> readCard(String cardId) {
    return db.readDocument(collection: 'cards', docId: cardId);
  }

  @override
  Stream<Map<String, dynamic>?> cardStream(String cardId) {
    return db.documentStream(collection: 'cards', docId: cardId);
  }

  @override
  Stream<List<Map<String, dynamic>>> cardsStream() {
    return db.collectionStream(collection: 'cards');
  }
}
