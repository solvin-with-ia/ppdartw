import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/infrastructure/gateways/fake_cards_gateway.dart';
import 'package:ppdartw/infrastructure/services/fake_service_ws_database.dart';

void main() {
  group('FakeCardsGateway', () {
    late FakeServiceWsDatabase db;
    late FakeCardsGateway gateway;
    setUp(() {
      db = FakeServiceWsDatabase();
      gateway = FakeCardsGateway(db);
    });

    final cardJson = {
      'id': 'c1',
      'display': '1',
      'value': 1,
      'description': 'Card 1',
      'isSpecial': false,
    };

    test('save and read card', () async {
      await gateway.saveCard(cardJson);
      final card = await gateway.readCard('c1');
      expect(card, isNotNull);
      expect(card!['id'], 'c1');
    });

    test('cardStream emits on save', () async {
      final emitted = <Map<String, dynamic>?>[];
      final sub = gateway.cardStream('c1').listen(emitted.add);
      await gateway.saveCard(cardJson);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(emitted.last, isNotNull);
      expect(emitted.last!['id'], 'c1');
      await sub.cancel();
    });

    test('cardsStream emits all cards', () async {
      final emitted = <List<Map<String, dynamic>>>[];
      final sub = gateway.cardsStream().listen(emitted.add);
      await gateway.saveCard(cardJson);
      await gateway.saveCard({...cardJson, 'id': 'c2'});
      await Future.delayed(const Duration(milliseconds: 10));
      expect(emitted.last.length, 2);
      expect(emitted.last.map((c) => c['id']).toSet(), {'c1', 'c2'});
      await sub.cancel();
    });
  });
}
