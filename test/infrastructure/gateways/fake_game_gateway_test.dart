import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/infrastructure/gateways/fake_game_gateway.dart';
import 'package:ppdartw/infrastructure/services/fake_service_ws_database.dart';

void main() {
  group('FakeGameGateway', () {
    late FakeServiceWsDatabase db;
    late FakeGameGateway gateway;
    setUp(() {
      db = FakeServiceWsDatabase();
      gateway = FakeGameGateway(db);
    });

    final gameJson = {
      'id': 'g1',
      'name': 'Test Game',
      'admin': {'id': 'admin1'},
      'players': [],
      'votes': [],
      'isActive': true,
      'createdAt': DateTime(2025, 1, 1).toIso8601String(),
      'finishedAt': null,
      'currentStory': '',
      'stories': <String>[],
      'deck': [],
      'revealTimeout': 30,
    };

    test('save and read game', () async {
      await gateway.saveGame(gameJson);
      final game = await gateway.readGame('g1');
      expect(game, isNotNull);
      expect(game!['id'], 'g1');
    });

    test('gameStream emits on save', () async {
      final emitted = <Map<String, dynamic>?>[];
      final sub = gateway.gameStream('g1').listen(emitted.add);
      await gateway.saveGame(gameJson);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(emitted.last, isNotNull);
      expect(emitted.last!['id'], 'g1');
      await sub.cancel();
    });

    test('gamesStream emits all games', () async {
      final emitted = <List<Map<String, dynamic>>>[];
      final sub = gateway.gamesStream().listen(emitted.add);
      await gateway.saveGame(gameJson);
      await gateway.saveGame({...gameJson, 'id': 'g2'});
      await Future.delayed(const Duration(milliseconds: 10));
      expect(emitted.last.length, 2);
      expect(emitted.last.map((g) => g['id']).toSet(), {'g1', 'g2'});
      await sub.cancel();
    });
  });
}
