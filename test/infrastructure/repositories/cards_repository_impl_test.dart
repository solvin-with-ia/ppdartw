import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/domain/models/card_model.dart';
import 'package:ppdartw/infrastructure/gateways/cards_gateway_impl.dart';
import 'package:ppdartw/infrastructure/repositories/cards_repository_impl.dart';
import 'package:ppdartw/infrastructure/services/fake_service_ws_database.dart';

void main() {
  group('CardsRepositoryImpl', () {
    late CardsRepositoryImpl repo;
    late CardsGatewayImpl gateway;
    setUp(() {
      gateway = CardsGatewayImpl(FakeServiceWsDatabase());
      repo = CardsRepositoryImpl(gateway);
    });

    const CardModel card = CardModel(
      id: 'c1',
      display: '1',
      value: 1,
      description: 'Card 1',
    );

    test('save and read card', () async {
      final Either<ErrorItem, void> saveResult = await repo.saveCard(card);
      saveResult.fold(
        (ErrorItem l) => fail('Should be right'),
        (void r) => expect(true, true),
      );
      final Either<ErrorItem, CardModel> readResult = await repo.readCard('c1');
      readResult.fold(
        (ErrorItem l) => fail('Should be right'),
        (CardModel r) => expect(r.id, 'c1'),
      );
    });

    test('cardStream emits card', () async {
      final List<Either<ErrorItem, CardModel?>> emitted =
          <Either<ErrorItem, CardModel?>>[];
      final StreamSubscription<Either<ErrorItem, CardModel?>> sub = repo
          .cardStream('c1')
          .listen(emitted.add);
      await repo.saveCard(card);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      emitted.last.fold(
        (ErrorItem l) => fail('Should be right'),
        (CardModel? r) => expect(r?.id, 'c1'),
      );
      await sub.cancel();
    });

    test('cardsStream emits all cards', () async {
      final List<Either<ErrorItem, List<CardModel>>> emitted =
          <Either<ErrorItem, List<CardModel>>>[];
      final StreamSubscription<Either<ErrorItem, List<CardModel>>> sub = repo
          .cardsStream()
          .listen(emitted.add);
      await repo.saveCard(card);
      await repo.saveCard(card.copyWith(id: 'c2'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      emitted.last.fold((ErrorItem l) => fail('Should be right'), (
        List<CardModel> r,
      ) {
        expect(r.length, 2);
        expect(r.map((CardModel c) => c.id).toSet(), <String>{'c1', 'c2'});
      });
      await sub.cancel();
    });
  });
}
