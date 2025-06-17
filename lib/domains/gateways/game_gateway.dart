abstract class GameGateway {
  Future<void> saveGame(Map<String, dynamic> gameJson);
  Future<Map<String, dynamic>?> readGame(String gameId);
  Stream<Map<String, dynamic>?> gameStream(String gameId);
  Stream<List<Map<String, dynamic>>> gamesStream();
}
