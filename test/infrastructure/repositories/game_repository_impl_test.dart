import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/domains/models/card_model.dart';
import 'package:ppdartw/domains/models/game_model.dart';
import 'package:ppdartw/domains/models/vote_model.dart';
import 'package:ppdartw/infrastructure/gateways/game_gateway_impl.dart';
import 'package:ppdartw/infrastructure/repositories/game_repository_impl.dart';
import 'package:ppdartw/infrastructure/services/fake_service_ws_database.dart';

void main() {
  group('GameRepositoryImpl', () {
    late GameRepositoryImpl repo;
    late GameGatewayImpl gateway;
    setUp(() {
      gateway = GameGatewayImpl(FakeServiceWsDatabase());
      repo = GameRepositoryImpl(gateway);
    });

    const UserModel fakeUser = UserModel(
      id: 'admin',
      displayName: 'Admin',
      email: 'admin@test.com',
      photoUrl: '',
      jwt: <String, dynamic>{},
    );
    final GameModel game = GameModel(
      id: 'g1',
      name: 'Test Game',
      admin: fakeUser,
      players: const <UserModel>[],
      spectators: const <UserModel>[],
      votes: const <VoteModel>[],
      isActive: true,
      createdAt: DateTime(2025),
      finishedAt: DateTime(2025, 1, 2),
      currentStory: '',
      deck: const <CardModel>[],
      revealTimeout: 30,
    );

    test('save and read game', () async {
      final Either<ErrorItem, void> saveResult = await repo.saveGame(game);
      expect(saveResult.isRight, true);
      final Either<ErrorItem, GameModel> readResult = await repo.readGame('g1');
      expect(readResult.isRight, true);
      readResult.fold(
        (ErrorItem l) => fail('Should be right'),
        (GameModel r) => expect(r.id, 'g1'),
      );
    });

    test('gameStream emits game', () async {
      final List<Either<ErrorItem, GameModel?>> emitted =
          <Either<ErrorItem, GameModel?>>[];
      final StreamSubscription<Either<ErrorItem, GameModel?>> sub = repo
          .gameStream('g1')
          .listen(emitted.add);
      await repo.saveGame(game);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emitted.last.isRight, true);
      emitted.last.fold(
        (ErrorItem l) => fail('Should be right'),
        (GameModel? r) => expect(r?.id, 'g1'),
      );
      await sub.cancel();
    });

    test('gamesStream emits all games', () async {
      final List<Either<ErrorItem, List<GameModel>>> emitted =
          <Either<ErrorItem, List<GameModel>>>[];
      final StreamSubscription<Either<ErrorItem, List<GameModel>>> sub = repo
          .gamesStream()
          .listen(emitted.add);
      await repo.saveGame(game);
      final GameModel game2 = GameModel(
        id: 'g2',
        name: 'Test Game 2',
        admin: fakeUser,
        players: const <UserModel>[],
        spectators: const <UserModel>[],
        votes: const <VoteModel>[],
        isActive: true,
        createdAt: DateTime(2025),
        finishedAt: DateTime(2025, 1, 2),
        currentStory: '',
        deck: const <CardModel>[],
        revealTimeout: 30,
      );
      await repo.saveGame(game2);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emitted.last.isRight, true);
      emitted.last.fold((ErrorItem l) => fail('Should be right'), (
        List<GameModel> r,
      ) {
        expect(r.length, 2);
        expect(r.map((GameModel g) => g.id).toSet(), <String>{'g1', 'g2'});
      });
      await sub.cancel();
    });
  });
}
