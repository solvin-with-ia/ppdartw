import '../../domain/gateways/game_gateway.dart';
import '../../domain/services/service_ws_database.dart';

class GameGatewayImpl implements GameGateway {
  GameGatewayImpl(this.db);
  final ServiceWsDatabase db;

  @override
  Future<void> saveGame(Map<String, dynamic> gameJson) {
    return db.saveDocument(
      collection: 'games',
      docId: gameJson['id'] as String,
      data: gameJson,
    );
  }

  @override
  Future<Map<String, dynamic>?> readGame(String gameId) {
    return db.readDocument(collection: 'games', docId: gameId);
  }

  @override
  Stream<Map<String, dynamic>?> gameStream(String gameId) {
    return db.documentStream(collection: 'games', docId: gameId);
  }

  @override
  Stream<List<Map<String, dynamic>>> gamesStream() {
    return db.collectionStream(collection: 'games');
  }
}
