import 'dart:async';

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

    final Map<String, Object?> gameJson = <String, Object?>{
      'id': 'g1',
      'name': 'Test Game',
      'admin': <String, String>{'id': 'admin1'},
      'players': <dynamic>[],
      'votes': <dynamic>[],
      'isActive': true,
      'createdAt': DateTime(2025).toIso8601String(),
      'finishedAt': null,
      'currentStory': '',
      'stories': <String>[],
      'deck': <dynamic>[],
      'revealTimeout': 30,
    };

    test('save and read game', () async {
      await gateway.saveGame(gameJson);
      final Map<String, dynamic>? game = await gateway.readGame('g1');
      expect(game, isNotNull);
      expect(game!['id'], 'g1');
    });

    test('gameStream emits on save', () async {
      final List<Map<String, dynamic>?> emitted = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub = gateway
          .gameStream('g1')
          .listen(emitted.add);
      await gateway.saveGame(gameJson);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emitted.last, isNotNull);
      expect(emitted.last!['id'], 'g1');
      await sub.cancel();
    });

    test('gamesStream emits all games', () async {
      final List<List<Map<String, dynamic>>> emitted =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub = gateway
          .gamesStream()
          .listen(emitted.add);
      await gateway.saveGame(gameJson);
      await gateway.saveGame(<String, dynamic>{...gameJson, 'id': 'g2'});
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emitted.last.length, 2);
      expect(
        emitted.last.map((Map<String, dynamic> g) => g['id']).toSet(),
        <String>{'g1', 'g2'},
      );
      await sub.cancel();
    });
  });
}
