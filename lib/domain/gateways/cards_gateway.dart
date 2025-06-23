abstract class CardsGateway {
  Future<void> saveCard(Map<String, dynamic> cardJson);
  Future<Map<String, dynamic>?> readCard(String cardId);
  Stream<Map<String, dynamic>?> cardStream(String cardId);
  Stream<List<Map<String, dynamic>>> cardsStream();
}
