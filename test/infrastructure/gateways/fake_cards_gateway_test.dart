import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/infrastructure/gateways/cards_gateway_impl.dart';
import 'package:ppdartw/infrastructure/services/fake_service_ws_database.dart';

void main() {
  group('FakeCardsGateway', () {
    late FakeServiceWsDatabase db;
    late CardsGatewayImpl gateway;
    setUp(() {
      db = FakeServiceWsDatabase();
      gateway = CardsGatewayImpl(db);
    });

    final Map<String, Object> cardJson = <String, Object>{
      'id': 'c1',
      'display': '1',
      'value': 1,
      'description': 'Card 1',
      'isSpecial': false,
    };

    test('save and read card', () async {
      await gateway.saveCard(cardJson);
      final Map<String, dynamic>? card = await gateway.readCard('c1');
      expect(card, isNotNull);
      expect(card!['id'], 'c1');
    });

    test('cardStream emits on save', () async {
      final List<Map<String, dynamic>?> emitted = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub = gateway
          .cardStream('c1')
          .listen(emitted.add);
      await gateway.saveCard(cardJson);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emitted.last, isNotNull);
      expect(emitted.last!['id'], 'c1');
      await sub.cancel();
    });

    test('cardsStream emits all cards', () async {
      final List<List<Map<String, dynamic>>> emitted =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub = gateway
          .cardsStream()
          .listen(emitted.add);
      await gateway.saveCard(cardJson);
      await gateway.saveCard(<String, dynamic>{...cardJson, 'id': 'c2'});
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emitted.last.length, 2);
      expect(
        emitted.last.map((Map<String, dynamic> c) => c['id']).toSet(),
        <String>{'c1', 'c2'},
      );
      await sub.cancel();
    });
  });
}
